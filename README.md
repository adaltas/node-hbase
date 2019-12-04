
[![Build Status](https://secure.travis-ci.org/adaltas/node-hbase.png)](http://travis-ci.org/adaltas/node-hbase)

[Node.js HBase](https://hbase.js.org) is a Node.JS client for the [Apache HBase](https://hbase.apache.org/)
database. It use the Rest API (Stargate) to communicate with HBase. Currently,
all the API is implemented and the data exchange format is JSON (but protocol
buffer could follow).

Apache HBase is part of the Hadoop ecosystem. It describes itself as the Hadoop
database optimized for random, realtime read/write access to big data. It is an
open-source, distributed, versioned, column-oriented store modeled after Google
Bigtable.

Client features include:

*   Intuitive API following Apache HBase naming conventions
*   Documentation and tests
*   Full Implementation of the REST API
*   Transparent encoding/decoding of values
*   Scanner and filter support implementing the `stream.Readable` API
*   Kerberos Support

## About HBase

Apache HBase is part of the Hadoop ecosystem from the Apache Software Foundation. It 
is a column oriented database (think NoSql) that really scale and is modelled 
after Google papers and its BigTable database.

## Installing

Via [npm](http://github.com/isaacs/npm):

```bash
npm install hbase
```

## Documentation

* [Index](./doc/index.md)   
  Getting started
* [Client](./doc/client.md)   
  Server information and object factory
* [Connection](./doc/connect.md)   
  HTTP REST requests
* [Row](./doc/row.md)   
  CRUD operation on rows and columns
* [Scanner](./doc/scanner.md)   
  Retrieve multiple rows and columns
* [Table](./doc/table.md)   
  Create, modify and delete HBase tables

## Quick example

The following code initialise a new HBase instance, create a table and a column family,
insert a record and read it.

```javascript
const hbase = require('hbase')
// Instantiate a new client
client = hbase({ host: '127.0.0.1', port: 8080 })
// Create a table
client
.table('my_table' )
.create('my_column_family', function(err, success){
  // Insert a record
  client
  .table('my_table' )
  .row('my_row')
  .put('my_column_family:my_column', 'my value', function(err, success){
    // Read a record
    client
    .table('my_table' )
    .row('my_row')
    .get('my_column_family', function(err, [cell]){
      // Validate the result
      assert(cell.key, 'my_row')
      assert(cell.column, 'my_column_family:my_column')
      assert(cell.$, 'my value')
    })
  })
})
```

Or shortly as:

```javascript
// Instantiate a new client
require('hbase')({ host: '127.0.0.1', port: 8080 })
// Create a table
.table('my_table' )
.create('my_column_family', function(err, success){
  // Insert a record
  this.put('my_column_family:my_column', 'my value', function(err, success){
    // Read a record
    this.get('my_column_family', function(err, [[cell]]){
      // Validate the result
      // ...
    })
  })
})
```

## Using Kerberos/SPNEGO

Options accepts a krb5 object. Password and keytab authentication are supported. 
Refer to the [krb5] package for additionnal information on how to configure the
krb5 option.

Using a keytab:

```javascript
const hbase = require('hbase');
hbase({
  host: '127.0.0.1',
  port: 8080,
  "krb5": {
    "principal": "{username}@{REALM}",
    "keytab": "{path/to/keytab}",
    "service_principal": "HTTP@{fqdn}"
  }
})
.version();
```

Using a password:

```javascript
const hbase = require('hbase');
hbase({
  host: '127.0.0.1',
  port: 8080,
  "krb5": {
    "principal": "{username}@{REALM}",
    "password": "{password}",
    "service_principal": "HTTP@{fqdn}"
  }
})
.version();
```

## Scanner and Filters

The scanner implement the `stream.Readable` API. For ease of usage, an optional
callback argument may be provided. For example:

```bash
client
.table('node_table')
.scan({
  startRow: 'my_row',
  maxVersions: 1
}, function(err, rows){
  console.log(err, rows);
});
```

is equivalent to:

```coffee
const rows = [];
scanner = client
.table('node_table')
.scan({
  startRow: 'my_row',
  maxVersions: 1
});
scanner.on('readable', function(){
  while(chunk = scanner.read()){
    rows.push(chunk);
  }
});
scanner.on('error', function(err){
  console.log(err);
});
scanner.on('end', function(){
  console.log(rows);
});
```

It can be quite a pain to figure out what options can be sent
with a scanner request. You will find a lot of examples inside the 
[Scanner test][scanner] and also look at the [examples][mt_samples] published by
[Marc Trudel][mt_home].

## More documentation

*   [Developer Guide](https://hbase.js.org/learn/developer/)
*   [Contributor Guide](https://hbase.js.org/learn/contribute/)

## Related projects

*   [Official Apache HBase project](http://hbase.apache.org)
*   [REST server bundled with HBase (Stargate)](https://wiki.apache.org/hadoop/Hbase/Stargate)

## Contributors

*   David Worms: <https://www.adaltas.com>
*   Michael Kurze: <https://github.com/michaelku>
*   Michal Taborsky: <https://github.com/whizz>
*   Pierre Sauvage: <https://github.com/Pierrotws>

This package is developed by [Adaltas](http://www.adaltas.com).

[ryba]: https://github.com/ryba-io/ryba
[scanner]: https://github.com/adaltas/node-hbase/blob/master/test/scanner.coffee
[mt_samples]: https://gist.github.com/3979381
[mt_home]: https://github.com/stelcheck
[krb5]: https://github.com/adaltas/node-krb5
