
# Row operations: CRUD operation on rows and columns

Row objects provide access and multipulation on colunns and rows. Single and multiple operations are available and are documented below.

## Dependencies

    utils = require './utils'
    Table = require './table'

## Grab an instance of "Row"

```javascript
var myRow = hbase({}).table('my_table').row('my_row');
```

Or

```javascript
var client = new hbase.Client({});
var myRow = new hbase.Row(client, 'my_table', 'my_row');
```

    Row = (client, table, key) ->
      @client = client
      @table = (if typeof table is "string" then table else table.name)
      @key = key
      @

## Retrieve values from HBase

```javascript
myRow.get([column], [options], callback);
```

Column is optional and corresponds to a column family optionnally followed by a column name separated with a column (":").

An optional object of options may contains the following properties:

-   start: timestamp indicating the minimal version date
-   end: timestamp indicating the maximal version date
-   v: maximum number of returned versions

Note: In our current release of HBase (0.98) the "v" option only work if a column is provided.

Callback is required and receive two arguments, an error object if any and the column value.

```javascript
hbase()
.table('my_table')
.row('my_row')
.get('my_column_family', {from: 1285942515900}, function(error, value){
  console.log(value);
});
```

Print something like

```cjson
[ { column: 'my_column_family:'
  , timestamp: 1285942722246
  , '$': 'my value 1'
  }
, { column: 'my_column_family:'
  , timestamp: 1285942705504
  , '$': 'my value 2'
  }
, { column: 'my_column_family:my_column'
  , timestamp: 1285942515955
  , '$': 'my value 3'
  }
]
```

Attempting to retrieve a column which does not exist in HBase will return a null value and an error whose code property is set to 404.

```javascript
hbase()
talbe('my_table')
.row('my_row')
.get('my_column_family:my_column', function(error, value){
  assert.strictEqual(404, error.code);
  assert.strictEqual(null, value);
});
```

## Retrieve values from multiple rows

Values from multiple rows is achieved by appending a suffix glob on the row key. Note the new "key" property present in the returned objects.

```javascript
hbase()
table('my_table')
.row('my_key_*')
.get('my_column_family:my_column', function(error, value){
  console.log(value);
});
```

Print something like

```javascript
[ { key: 'my_key_1',
  , column: 'my_column_family:my_column'
  , timestamp: 1285942781739
  , '$': 'my value 1'
  }
, { key: 'my_key_2',
  , column: 'my_column_family:my_column'
  , timestamp: 12859425923984
  , '$': 'my value 2'
  }
]
```

    Row::get = (column, callback) ->
      args = Array::slice.call(arguments)
      key = "/" + @table + "/" + @key
      isGlob = @key.substr(-1, 1) is "*"
      options = {}
      columns = null
      start = null
      end = null
      params = {}
      columns = args.shift()  if typeof args[0] is "string" or (typeof args[0] is "object" and args[0] instanceof Array)
      options = args.shift()  if typeof args[0] is "object"
      start = options.start  if options.start
      end = options.end  if options.end
      params.v = options.v  if options.v
      url = utils.url.encode table: @table, key: @key, columns: columns, start: start, end: end, params: params
      @client.connection.get url, (error, data) =>
        return args[0].apply(@, [error, null])  if error
        cells = []
        data.Row.forEach (row) =>
          key = utils.base64.decode row.key, @client.options.encoding
          row.Cell.forEach (cell) =>
            data = {}
            data.key = key if isGlob
            data.column = utils.base64.decode cell.column, @client.options.encoding
            data.timestamp = cell.timestamp
            data.$ = utils.base64.decode cell.$, @client.options.encoding
            cells.push data
        args[0].apply @, [null, cells]

## Insert and update a column value

```javascript
myRow.put(column, data, [timestamp], callback);
```

Column is required and corresponds to a column family optionnally followed by a column name separated with a column (":").

Callback is optional and receive two arguments, an error object if any and a boolean indicating whether the column was inserted/updated or not.

```javascript
hbase()
.table('my_table')
.row('my_row')
.put('my_column_family:my_column', 'my value', function(error, success){
  assert.strictEqual(true, success);
});
```

## Insert and update multiple column values

```javascript
myRow.put(columns, values, [timestamps], callback);
myRow.put(data, callback);
```

Inserting values into multiple columns is achieved the same way as for a single column but the column and data arguments must be an array of the same length.

```javascript
hbase()
.table('my_table')
.row('my_row')
.put(
  ['my_column_family:my_column_1', 'my_column_family:my_column_2'],
  ['my value 1', 'my value 2'],
  function(error, success){
    assert.strictEqual(true, success);
  }
);
```

Alternatively, you could provide an array of cells as below:

```javascript
var cells =
  [ { column: 'cf:c1', timestamp: Date.now(), $: 'my value' }
  , { column: 'cf:c2', timestamp: Date.now(), $: 'my value' }
  , { column: 'cf:c1', timestamp: Date.now()+1, $: 'my value' }
  ];
hbase()
.table('my_table')
.row('my_row')
.put(cells, function(error, success){
  assert.strictEqual(true, success);
});
```

## Insert and update multiple rows

```javascript
myRow.put(data, callback);
```

HBase allows us to send multiple cells from multiple rows in batch. To achieve it, construct a new row with a null key and provide the `put` function with an array of cells. Each cell objects must include the row `key`, `column` and `$` properties while `timestamp` is optional.

```javascript
var rows = 
  [ { key: 'row_1', column: 'cf:c1', timestamp: Date.now(), $: 'my value' }
  , { key: 'row_1', column: 'cf:c2', timestamp: Date.now(), $: 'my value' }
  , { key: 'row_2', column: 'cf:c1', timestamp: Date.now()+1, $: 'my value' }
  ];
hbase()
.table('my_table')
.row()
.put(rows, function(error,success){
  assert.strictEqual(true, success);
});
```

    Row::put = (columns, values, callback) ->
      args = Array::slice.call(arguments)
      url = undefined
      body = undefined
      bodyRow = undefined
      # First argument are columns and second argument are values
      if args.length > 2
        columns = args.shift()
        values = args.shift()
        timestamps = undefined
        timestamps = args.shift()  if typeof args[0] isnt "function"
        callback = args.shift()
        if typeof columns is "string"
          columns = [columns]
          values = [values]
        else throw new Error("Columns count must match values count")  if columns.length isnt values.length
        body = Row: []
        bodyRow =
          key: utils.base64.encode @key, @client.options.encoding
          Cell: []
        columns.forEach (column, i) =>
          bodyCell = {}
          bodyCell.timestamp = timestamps[i]  if timestamps
          bodyCell.column = utils.base64.encode column, @client.options.encoding
          bodyCell.$ = utils.base64.encode values[i], @client.options.encoding
          bodyRow.Cell.push bodyCell
        body.Row.push bodyRow
        url = utils.url.encode table: @table, key: @key or "___false-row-key___", columns: columns
      # First argument is a full object with columns and values
      else
        data = args.shift()
        callback = args.shift()
        body = Row: []
        cellsKeys = {}
        data.forEach (d) =>
          key = d.key or @key
          cellsKeys[key] = []  unless key of cellsKeys
          cellsKeys[key].push d
        for k of cellsKeys
          cells = cellsKeys[k]
          bodyRow =
            key: utils.base64.encode k, @client.options.encoding
            Cell: []
          for k1 of cells
            cell = cells[k1]
            bodyCell = {}
            bodyCell.timestamp = "" + cell.timestamp  if cell.timestamp
            bodyCell.column = utils.base64.encode cell.column, @client.options.encoding
            bodyCell.$ = utils.base64.encode cell.$, @client.options.encoding
            bodyRow.Cell.push bodyCell
          body.Row.push bodyRow
        url = utils.url.encode table: @table, key: @key or "___false-row-key___", columns: ['test:']
      # console.log '>>', url, require('util').inspect body, showHidden: false, depth: null
      @client.connection.put url, body, (error, data) =>
        return  unless callback
        callback.apply @, [error, (if error then null else true)]

## Test if a row or a column exists

```javascript
myRow.exists([column], callback);
```

Column is optional and corresponds to a column family optionnally followed by a column name separated with a column (":").

Callback is required and receive two arguments, an error object if any and a boolean indicating whether the column exists or not.

Example to see if a row exists:

```javascript
hbase()
.table('my_table')
.row('my_row')
.exists(function(error, exists){
  assert.strictEqual(true, exists);
});
```

Example to see if a column exists:

```javascript
hbase()
.table('my_table')
.row('my_row')
.exists('my_column_family:my_column', function(error, exists){
  assert.strictEqual(true, exists);
});
```

    Row::exists = (column, callback) ->
      args = Array::slice.call(arguments)
      column = (if typeof args[0] is "string" then args.shift() else null)
      url = utils.url.encode table: @table, key: @key, columns: column
      @client.connection.get url, (error, exists) =>
        # note:
        # if row does not exists: 404
        # if row exists and column family does not exists: 503
        if error and (error.code is 404 or error.code is 503)
          error = null
          exists = false
        args[0].apply @, [error, (if error then null else ((if exists is false then false else true)))]

## Delete a row or a column

```javascript
myRow.delete([column], callback);
```

Column is optional and corresponds to a column family optionnally followed by a column name separated with a column (":").

Callback is required and receive two arguments, an error object if any and a boolean indicating whether the column exists or not.

Example to delete a row:

```javascript
hbase()
.table('my_table')
.row('my_row')
.delete(function(error, success){
  assert.strictEqual(true, success);
});
```

Example to delete a column:

```javascript
hbase()
.table('my_table')
.row('my_row')
.delete('my_column_family:my_column', function(error, success){
  assert.strictEqual(true, success);
});
```

## Delete multiple columns

Deleting multiple columns is achieved by providing an array of columns as the first argument.

```javascript
hbase()
.table('my_table')
.row('my_row')
.delete(
  ['my_column_family:my_column_1', 'my_column_family:my_column_2'],
  function(error, success){
    assert.strictEqual(true, success);
  }
);
```

    Row::delete = ->
      args = Array::slice.call(arguments)
      columns = undefined
      columns = args.shift()  if typeof args[0] is "string" or (typeof args[0] is "object" and args[0] instanceof Array)
      url = utils.url.encode table: @table, key: @key, columns: columns
      @client.connection.delete url, ((error, success) =>
        args[0].apply @, [error, (if error then null else true)]
      ), true

    module.exports = Row
