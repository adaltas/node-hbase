
# Scanner operations

Scanner are the most efficient way to retrieve multiple 
rows and columns from HBase.

## Dependencies

    util = require 'util'
    utils = require './utils'
    Table = require './table'
    {Readable} = require 'stream'

## Grab an instance of "Scanner"

```javascript
var myScanner = hbase({}).table('my_table').scan(...);
```

Or

```javascript
var client = new hbase.Client({});
var myScanner = new hbase.Scanner(client, {table: 'my_table'});
```

## Options

All options except the "table" option are optional. The following properties are
available:

*   `startRow`
    First row returned by the scanner.   
*   `endRow`
    Row stopping the scanner, not returned by the scanner.   
*   `columns`
    Filter the scanner by columns (a string or an array of columns).   
*   `batch`
    Number of cells returned on each iteration, internal use, default to "1000".   
*   `maxVersions`
    Number of returned version for each row.   
*   `startTime`
    Row minimal timestamp version.   
*   `endTime`
    Row maxiam timestamp version.   
*   `filter`
    See below for more informations.   
*   `encoding`
    Default to client.options.encoding, set to null to overwrite default
    encoding and return a buffer.   

## Using filter

Filter are defined during the scanner creation. If you
are familiar with HBase filters, it will be real easy to
use them. Note, you should not worry about encoding the
values, the library will do it for you. When you create
a new scanner, just associate the `filter` property with  
your filter object. All filters are supported.   

Many examples are available in the tests but here's one
wich returns all rows starting by "my_key_" and whose
value is "here you are".   

```javascript
client.table('my_tb').scan({
  filter: {
  "op":"MUST_PASS_ALL","type":"FilterList","filters":[{
      "op":"EQUAL",
      "type":"RowFilter",
      "comparator":{"value":"my_key_.+","type":"RegexStringComparator"}
    },{
      "op":"EQUAL",
      "type":"ValueFilter",
      "comparator":{"value":"here you are","type":"BinaryComparator"}
    }
  ]}
}, function(error, cells){
  assert.ifError(error);
});
```

    Scanner = (client, @options={}) ->
      @options.objectMode = true
      Readable.call(@, @options);
      @client = client
      # @table = if typeof table is 'string' then table else table.name
      # @id = id or null
      @options = table: @options if typeof @options is 'string'
      throw Error 'Missing required option "table"' unless @options.table
      @options.id = null
      @callback = null

    util.inherits Scanner, Readable

## `Scanner.init(callback)`

Create a new scanner and return its ID.

    Scanner::init = (callback) ->
      # options = utils.merge {}, @options
      params = {}
      params.batch ?= 1000
      key = "/#{@options.table}/scanner"
      encoding = if @options.encoding is 'undefined' then @options.encoding else @client.options.encoding
      params.startRow = utils.base64.encode(@options.startRow, encoding) if @options.startRow
      params.endRow = utils.base64.encode(@options.endRow, encoding) if @options.endRow
      params.maxVersions = @options.maxVersions if @options.maxVersions
      if @options.column
        params.column = []
        @options.column = [@options.column] if typeof @options.column is 'string'
        @options.column.forEach (column, i) ->
          params.column[i] = utils.base64.encode column, encoding
      if @options.filter
        encode = (obj) ->
          for k of obj
            if k is 'value' and (not obj['type'] or obj['type'] isnt 'RegexStringComparator' and obj['type'] isnt 'PageFilter')
              obj[k] = utils.base64.encode obj[k], encoding
            else encode obj[k]  if typeof obj[k] is 'object'
        encode @options.filter
        params.filter = JSON.stringify(@options.filter)
      @client.connection.put key, params, (err, data, response) =>
        return callback err if err
        id = /scanner\/(\w+)$/.exec(response.headers.location)[1]
        @options.id = id
        callback null, id

## `Scanner.get(callback)`

Retrieve the next cells from HBase. The callback is required
and receive two arguments, an error object if any and a array
of cells or null if the scanner is exhausted.
```

    Scanner::get = (callback) ->
      key = "/#{@table}/scanner/#{@options.id}"
      @client.connection.get key, (err, data, response) =>
        # result is successful but the scanner is exhausted, returns HTTP 204 status (no content)
        return callback() if response and response.statusCode is 204
        return callback err if err
        cells = []
        data.Row.forEach (row) =>
          key = utils.base64.decode row.key, @client.options.encoding
          row.Cell.forEach (cell) =>
            data = {}
            data.key = key
            data.column = utils.base64.decode cell.column, @client.options.encoding
            data.timestamp = cell.timestamp
            data.$ = utils.base64.decode cell.$, @client.options.encoding
            cells.push data
        callback null, cells

## `Scanner.delete(callback)`

Delete a scanner.

```javascript
myScanner.delete(callback);
```

Callback is optionnal and receive two arguments, an 
error object if any and a boolean indicating whether 
the scanner was removed or not.

    Scanner::delete = (callback) ->
      @client.connection.delete "/#{@table}/scanner/#{@options.id}", callback

## Scanner._read(size)

Implementation of the `stream.Readable` API.

    Scanner::_read = (size) ->
      return if @done
      unless @options.id
        return @init (err, id) =>
          return @emit 'error', err if err
          @_read()
      @get (err, cells) =>
        return if @done
        return @emit 'error', err if err
        unless cells
          @done = true
          return @delete (err) =>
            return @emit 'error', err if err
            @push null
        for cell in cells
          @push cell

    module.exports = Scanner
