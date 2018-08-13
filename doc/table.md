
# Table operations: create, modify and delete HBase tables

## Grab an instance of "hbase.Table"

```javascript
var myTable = hbase({}).table('my_table');
```

Or

```javascript
var client = new hbase.Client({});
var myTable = new hbase.Table(client, 'my_table');
```

## Create a new table in HBase

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
.table('my_new_table')
.create('my_new_column', function(error, success){
  console.log('Table created: ' + (success ? 'yes' : 'no'));
} );
```

For more control on the table and column family schema configuration, the
argument may be a full schema object. It doesn't need to contain the "name"
property as it will be injected but may  contain the keys `is_meta` and
`is_root` as well as the column family schemas. The column property must contain
the key "name" and any other valid keys (`blocksize`, `bloomfilter`,
`blockcache`, `compression`, `length`, `versions`, `ttl` and `in_memory`).

```javascript
hbase()
.table('my_new_table')
.create({
  IS_META: false,
  IS_ROOT: false,
  COLUMNS: [{
    NAME: 'my_new_column'
  }]
}, (error, success) => {
  console.info('Table created: ' + (success ? 'yes' : 'no'))
})
```

## Drop an existing table

```javascript
myTable.delete(callback);
```

Callback is optional and receives two arguments, an error object if any and a
boolean indicating whether the table was removed/disabled or not.

```javascript
hbase()
.table('my_table')
.delete((error, success) => {
  assert.ok(success)
})
```

## Check if a table is created

```javascript
myTable.exists(calblack);
```

## Update an existing table

NOT YET WORKING, waiting for [HBASE-3140](https://issues.apache.org/jira/browse/HBASE-3140).

## Retrieves table schema

```javascript
hbase()
.table( 'my_new_table' )
.schema(function(error, schema){
  console.log(schema);
});
```

Will print something similar to:

```json
{ "name": "node_hbase"
, "IS_META": "false"
, "IS_ROOT": "false"
, "ColumnSchema":
   [ { "name": "column_2"
   , "BLOCKSIZE": "65536"
   , "BLOOMFILTER": "NONE"
   , "BLOCKCACHE": "true"
   , "COMPRESSION": "NONE"
   , "VERSIONS": "3"
   , "REPLICATION_SCOPE": "0"
   , "TTL": "2147483647"
   , "IN_MEMORY": "false"
   }
   ]
}
```

## Retrieves table region metadata

```javascript
hbase()
.table( 'my_new_table' )
.regions(function(error, regions){
  console.log(regions);
});
```

Will print something similar to:

```json
{ "name": "node_hbase"
, "Region": 
   [ { "startKey": ""
   , "name": "node_hbase,,1285801694075"
   , "location": "node_01.domain:56243"
   , "id": 1285801694075
   , "endKey": ""
   }
   ]
}
```

## Return a new row instance

```javascript
Table.row(key)
```


## Return a new scanner instance

```javascript
Table.scan(options, [callback])
```
