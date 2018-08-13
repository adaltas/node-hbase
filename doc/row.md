
# Row operations: CRUD operation on rows and columns

Row objects provide access and manipulation on colunns and rows. Single and
multiple operations are available and are documented below.

## Grab an instance of "Row"

```javascript
const myRow = hbase({}).table('my_table').row('my_row');
```

Or

```javascript
const client = new hbase.Client({})
const myRow = new hbase.Row(client, 'my_table', 'my_row')
```

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
.get('my_column_family', {from: 1285942515900}, (error, value) => {
  console.log(value)
})
```

Print something like

```json
[ { "column": "my_column_family:"
  , "timestamp": 1285942722246
  , "$": "my value 1"
  }
, { "column": "my_column_family:"
  , "timestamp": 1285942705504
  , "$": "my value 2"
  }
, { "column": "my_column_family:my_column"
  , "timestamp": 1285942515955
  , "$": "my value 3"
  }
]
```

Attempting to retrieve a column which does not exist in HBase will return a null value and an error whose code property is set to 404.

```javascript
hbase()
talbe('my_table')
.row('my_row')
.get('my_column_family:my_column', (error, value) => {
  assert.strictEqual(404, error.code)
  assert.strictEqual(null, value)
})
```

## Retrieve values from multiple rows

Values from multiple rows is achieved by appending a suffix glob on the row key. Note the new "key" property present in the returned objects.

```javascript
hbase()
table('my_table')
.row('my_key_*')
.get('my_column_family:my_column', (error, value) => {
  console.info(value)
})
```

Print something like

```json
[ { "key": "my_key_1"
  , "column": "my_column_family:my_column"
  , "timestamp": 1285942781739
  , "$": "my value 1"
  }
, { "key": "my_key_2"
  , "column": "my_column_family:my_column"
  , "timestamp": 12859425923984
  , "$": "my value 2"
  }
]
```

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
.put('my_column_family:my_column', 'my value', (error, success) => {
  assert.strictEqual(true, success)
})
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
  (error, success) => {
    assert.strictEqual(true, success);
  }
)
```

Alternatively, you could provide an array of cells as below:

```javascript
const cells =
  [ { column: 'cf:c1', timestamp: Date.now(), $: 'my value' }
  , { column: 'cf:c2', timestamp: Date.now(), $: 'my value' }
  , { column: 'cf:c1', timestamp: Date.now()+1, $: 'my value' }
  ]
hbase()
.table('my_table')
.row('my_row')
.put(cells, (error, success) => {
  assert.strictEqual(true, success)
})
```

## Insert and update multiple rows

```javascript
myRow.put(data, callback);
```

HBase allows us to send multiple cells from multiple rows in batch. To achieve it, construct a new row with a null key and provide the `put` function with an array of cells. Each cell objects must include the row `key`, `column` and `$` properties while `timestamp` is optional.

```javascript
const rows = 
  [ { key: 'row_1', column: 'cf:c1', timestamp: Date.now(), $: 'my value' }
  , { key: 'row_1', column: 'cf:c2', timestamp: Date.now(), $: 'my value' }
  , { key: 'row_2', column: 'cf:c1', timestamp: Date.now()+1, $: 'my value' }
  ]
hbase()
.table('my_table')
.row()
.put(rows, (error,success) => {
  assert.strictEqual(true, success)
})
```

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
.exists((error, exists) => {
  assert.strictEqual(true, exists)
})
```

Example to see if a column exists:

```javascript
hbase()
.table('my_table')
.row('my_row')
.exists('my_column_family:my_column', (error, exists) => {
  assert.strictEqual(true, exists)
})
```

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
.delete((error, success) => {
  assert.strictEqual(true, success)
})
```

Example to delete a column:

```javascript
hbase()
.table('my_table')
.row('my_row')
.delete('my_column_family:my_column', (error, success) => {
  assert.strictEqual(true, success)
})
```

## Delete multiple columns

Deleting multiple columns is achieved by providing an array of columns as the first argument.

```javascript
hbase()
.table('my_table')
.row('my_row')
.delete(
  ['my_column_family:my_column_1', 'my_column_family:my_column_2'],
  (error, success) => {
    assert.strictEqual(true, success)
  }
)
```
