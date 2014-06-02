utils = require './utils'
Table = require './table'

###
Scanner operations
==================

Scanner are the most efficient way to retrieve multiple 
rows and columns from HBase.

Grab an instance of "Scanner"
-----------------------------

```javascript
var myScanner = hbase({}).getScanner('my_table');
var myScanner = hbase({}).getScanner('my_table','my_id');
```

Or

```javascript
var myScanner = hbase({}).getTable('my_table').getScanner();
var myScanner = hbase({}).getTable('my_table').getScanner('my_id');
```

Or

```javascript
var client = new hbase.Client({});
var myScanner = new hbase.Scanner(client, 'my_table');
var myScanner = new hbase.Scanner(client, 'my_table', 'my_id');
```

Using filter
------------

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
myScanner.create({
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
###
Scanner = (client, table, id) ->
  @client = client
  @table = if typeof table is 'string' then table else table.name
  @id = id or null
  @callback = null

###
`Scanner.create([params], callback)`
------------------------------------

Create a new scanner.

```javascript
myScanner.create([params], callback);
```

Params is an object for which all properties are optional. The
following properties are available:

-   startRow: First row returned by the scanner   
-   endRow: Row stopping the scanner, not returned by the scanner   
-   columns: Filter the scanner by columns (a string or an array of columns)   
-   batch: Number of cells returned on each iteration   
-   startTime   
-   endTime   
-   filter: see below for more informations   
###
Scanner::create = (params, callback) ->
  self = this
  args = Array::slice.call arguments
  key = "/#{@table}/scanner"
  params = if typeof args[0] is 'object' then args.shift() else {}
  callback = args.shift()
  params.startRow = utils.base64.encode(params.startRow)  if params.startRow
  params.endRow = utils.base64.encode(params.endRow)  if params.endRow
  if params.column
    if typeof params.column is 'string'
      params.column = utils.base64.encode params.column
    else
      params.column.forEach (column, i) ->
        params.column[i] = utils.base64.encode column

  if params.filter
    encode = (obj) ->
      for k of obj
        if k is 'value' and (not obj['type'] or obj['type'] isnt 'RegexStringComparator' and obj['type'] isnt 'PageFilter')
          obj[k] = utils.base64.encode(obj[k])
        else encode obj[k]  if typeof obj[k] is 'object'

    encode params.filter
    params.filter = JSON.stringify(params.filter)
  @client.connection.put key, params, (error, data, response) ->
    return callback.apply(self, [error, null])  if error
    id = /scanner\/(\w+)$/.exec(response.headers.location)[1]
    self.id = id
    callback.apply self, [null, id]

###
`Scanner.get(callback)`
-----------------------

Scanning records.

```javascript
myScanner.get(callback);
```

Retrieve the next cells from HBase. The callback is required
and receive two arguments, an error object if any and a array
of cells or null if the scanner is exhausted.

The number of cells depends on the `batch` option. It is your
responsibity to call `get` as long as more cells are expected.

```javascript
var callback = function(error, cells){
  assert.ifError(error);
  if(cells){
    // do something
    console.log(cells);
    // call the next iteration
    myScanner.get(callback)
  }else{
    // no more cells to iterate
  }
};
myScanner.get(callback);
```

Note, this is not very pretty. Alternatively, you could make
use of the scanner function `continue` inside your callback
to trigger a new iteration. Here's how:
  
```javascript
myScanner.get(function(error, cells){
  assert.ifError(error);
  if(cells){
    // do something
    console.log(cells);
    // call the next iteration
    this.continue()
  }else{
    // no more cells to iterate
    // delete the scanner
    this.delete();
  }
});
```
###
Scanner::get = (callback) ->
  self = this
  key = "/#{@table}/scanner/#{@id}"
  if callback
    @callback = callback
  else
    callback = @callback
  @client.connection.get key, (error, data, response) ->
    # result is successful but the scanner is exhausted, returns HTTP 204 status (no content)
    return callback.apply self, [null, null] if response and response.statusCode is 204
    return callback.apply self, [error, null] if error
    cells = []
    data.Row.forEach (row) ->
      key = utils.base64.decode row.key
      row.Cell.forEach (cell) ->
        data = {}
        data.key = key
        data.column = utils.base64.decode cell.column
        data.timestamp = cell.timestamp
        data.$ = utils.base64.decode cell.$
        cells.push data
    callback.apply self, [null, cells]

###
`Scanner.continue()`
--------------------
###
Scanner::continue = ->
  @get()

###
`Scanner.delete(callback)`
--------------------------

Delete a scanner.

```javascript
myScanner.delete(callback);
```

Callback is optionnal and receive two arguments, an 
error object if any and a boolean indicating whether 
the scanner was removed or not.
###
Scanner::delete = (callback) ->
  self = this
  key = "/#{@table}/scanner/#{@id}"
  @client.connection.delete key, (error, success) ->
    unless callback
      if error
        throw error
      else
        return
    callback.apply self, [error, if error then null else true]

module.exports = Scanner
