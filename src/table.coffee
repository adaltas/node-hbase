Row = require './row'
Scanner = require './scanner'

###
Table operations: create, modify and delete HBase tables
========================================================

Grab an instance of "hbase.Table"
---------------------------------

```javascript
var myTable = hbase({}).getTable('my_table');
```

Or

```javascript
var client = new hbase.Client({});
var myTable = new hbase.Table(client, 'my_table');
```
###
Table = (client, name) ->
  @client = client
  @name = name
  @

###
Create a new table in HBase
---------------------------

```javascript
myTable.create(callback)
```

Callback is optionnal and receive two arguments, an 
error object if any and a boolean indicating whether 
the table was created or not.

The simplest way is to grab a table object and call 
its `create` function with the schema as argument.

```javascript
hbase()
.getTable('my_new_table')
.create('my_new_column', function(error, success){
  console.log('Table created: ' + (success ? 'yes' : 'no'));
} );
```

For more control on the table and column family schema
 configuration, the argument may be a full schema object. 
 It doesn't need to contain the "name" property as it will 
 be injected but may  contain the keys "is_meta" and "is_root" 
 as well as the column family schemas. The column property 
 must contain the key "name" and any other valid keys 
 ("blocksize", "bloomfilter", "blockcache", "compression", 
 "length", "versions", "ttl" and "in_memory").

```javascript
hbase()
.getTable( 'my_new_table' )
.create( {
  IS_META: false,
  IS_ROOT: false,
  COLUMNS: [{
    NAME: 'my_new_column'
  }]
}, function( error, success ){
  console.log('Table created: ' + (success ? 'yes' : 'no'));
} );
```
###
Table::create = (schema, callback) ->
  self = this
  args = Array::slice.call(arguments)
  schema = if args.length and typeof args[0] is 'object' or typeof args[0] is 'string' then args.shift() else {}
  callback = if args.length then args.shift() else null
  schema.name = @name
  schema = ColumnSchema: [name: schema]  if typeof schema is 'string'
  @client.connection.put "/#{@name}/schema", schema, (error, data) ->
    unless callback
      if error
        throw error
      else
        return
    callback.apply self, [error, if error then null else true]

###
Drop an existing table
----------------------

```javascript
myTable.delete(callback);
```

Callback is optionnal and receive two arguments, an error object if any and a boolean indicating whether the table was removed/disabled or not.

```javascript
hbase()
.getTable('my_table')
.delete(function(error, success){
  assert.ok(success);
});
```
###
Table::delete = (callback) ->
  self = this
  @client.connection.delete "/#{@name}/schema", (error, data) ->
    unless callback
      if error
        throw error
      else
        return
    callback.apply self, [error, if error then null else true]

###
Check if a table is created
---------------------------

```javascript
myTable.exists(calblack);
```
###
Table::exists = (callback) ->
  self = this
  @client.connection.get "/#{@name}/exists", (error, exists) ->
    if error and error.code is 404
      error = null
      exists = false
    callback.apply self, [error, if error then null else (exists isnt false)]

###
Update an existing table
------------------------

NOT YET WORKING, waiting for [HBASE-3140](https://issues.apache.org/jira/browse/HBASE-3140).
###
Table::update = (schema, callback) ->
  self = this
  schema.name = @name
  @client.connection.post "/#{@name}/schema", schema, (error, data) ->
    unless callback
      if error
        throw error
      else
        return
    callback.apply self, [error, if error then null else true]

###
Retrieves table schema
----------------------

```javascript
hbase()
.getTable( 'my_new_table' )
.getSchema(function(error, schema){
  console.log(schema);
});
```

Will print something similar to:

```json
{ name: 'node_hbase'
, IS_META: 'false'
, IS_ROOT: 'false'
, ColumnSchema:
   [ { name: 'column_2'
   , BLOCKSIZE: '65536'
   , BLOOMFILTER: 'NONE'
   , BLOCKCACHE: 'true'
   , COMPRESSION: 'NONE'
   , VERSIONS: '3'
   , REPLICATION_SCOPE: '0'
   , TTL: '2147483647'
   , IN_MEMORY: 'false'
   }
   ]
}
```
###
Table::getSchema = (callback) ->
  self = this
  @client.connection.get "/#{@name}/schema", (error, data) ->
    callback.apply self, [error, if error then null else data]

###
Retrieves table region metadata
-------------------------------

```javascript
hbase()
.getTable( 'my_new_table' )
.getRegions(function(error, regions){
  console.log(regions);
});
```

Will print something similar to:

```json
{ name: 'node_hbase'
, Region: 
   [ { startKey: ''
   , name: 'node_hbase,,1285801694075'
   , location: 'eha.home:56243'
   , id: 1285801694075
   , endKey: ''
   }
   ]
}
```
###
Table::getRegions = (callback) ->
  self = this
  @client.connection.get "/#{@name}/regions", (error, data) ->
    callback.apply self, [error, if error then null else data]

###
Return a new row instance
-----------------

```javascript
Table.getRow(key)
```

###
Table::getRow = (key) ->
  new Row @client, @name, key


###
Return a new scanner instance
---------------------

```javascript
Table.getScanner(key)
```
###
Table::getScanner = (id) ->
  new Scanner @client, @name, id

module.exports = Table
