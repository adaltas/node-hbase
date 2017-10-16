
[![Build Status](https://secure.travis-ci.org/adaltas/node-hbase.png)](http://travis-ci.org/adaltas/node-hbase)

Node HBase is a Node.JS client for the Apache HBase database. It use the Rest
API (Stargate) to communicate with HBase. Currently, all the API is implemented
and the data exchange format is JSON (but protocol buffer could follow).

Apache HBase is part of the Hadoop ecosystem. It describes itself as the Hadoop
database optimized for random, realtime read/write access to big data. It is an
open-source, distributed, versioned, column-oriented store modeled after Google
Bigtable.

Client features include:

*   Intuitive API following HBase naming conventions
*   Documentation and tests
*   Full Implementation of the REST API
*   Transparent encoding/decoding of values
*   Scanner and filter support implementing the `stream.Readable` API
*   Kerberos Support

## About HBase

HBase is part of the Hadoop ecosystem from the Apache Software Foundation. It 
is a column oriented database (think NoSql) that really scale and is modelled 
after Google papers and its BigTable database.

## Installing

Via [npm](http://github.com/isaacs/npm):

```bash
npm install hbase
```

## Documentation

* [Index](./blob/master/src/index.coffee.md)   
  Getting started
* [Client](./blob/master/src/client.coffee.md)   
  Server information and object factory
* [Connection](./blob/master/src/connect.coffee.md)   
  HTTP REST requests
* [Row](./blob/master/src/row.coffee.md)   
  CRUD operation on rows and columns
* [Scanner](./blob/master/src/scanner.coffee.md)   
  Retrieve multiple rows and columns
* [Table](./blob/master/src/table.coffee.md)   
  Create, modify and delete HBase tables

## Quick example

This code create a new HBase instance, create a table and a column family,
insert a few records and traverse them.

```javascript
var assert = require('assert');
var hbase = require('hbase');

hbase({ host: '127.0.0.1', port: 8080 })
.table('my_table' )
.create('my_column_family', function(err, success){
  this
  .row('my_row')
  .put('my_column_family:my_column', 'my value', function(err, success){
    this.get('my_column_family', function(err, cells){
      this.exists(function(err, exists){
        assert.ok(exists);
      });
    });
  });
});
```

## Using Kerberos/SPNEGO

Options accepts a krb5 object. Password and keytab authentication are supported. 
Refer to the [krb5] package for additionnal information on how to configure the
krb5 option.

Using a keytab:

```
var hbase = require('hbase');
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

```
var hbase = require('hbase');
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
var rows = [];
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

## Running the tests

Tests are executed with mocha. Before running the tests the first time, copy the
file "./test/properties.json.sample" to "./test/properties.json" and make the
appropriate changes.

If using the HDP sandbox, start the virtual machine, log-in as "root", start
Ambari `start_ambari.sh`, start HBase `start_hbase.sh` and start the HBase REST
server `/usr/lib/hbase/bin/hbase rest -p 60080`.
Otherwise you can run HBase in locally with 
`docker run --name stargate --rm -p 60080:8080 sixeyed/hbase-stargate`
`docker run --name stargate -p 2181:2181 -p 60010:60010 -p 60000:60000 -p 60020:60020 -p 60030:60030 -p 60080:8080 -p 8085:8085 sixeyed/hbase-stargate`

To run the tests:

```bash
npm test
```

There is also a Dockerfile under `hbase-rest-reverse-proxy/` that creates an Nginx reverse proxy to HBase REST. This image can be used to test cases where the REST service runs behind a proxy. The file `test/properties_with_path.docker.coffee` can be used to test scenarios where HBase REST is accessible through a custom path (`/rest`).

When testing against HBase secured with Kerberos, you must create a table with
the right ownership.

```bash
kinit hbase
hbase shell
create 'node_table', {NAME => 'node_column_family', VERSIONS => 5}
grant 'ryba', 'RWC', 'node_table'
```

You can use the example located in "test/properties.json.krb5" to configure the
test. It comes pre-configured for [Ryba] configured in development cluster mode.

## Related projects

*   [Official Apache HBase project](http://hbase.apache.org)
*   [REST server bundled with HBase (Stargate)](https://wiki.apache.org/hadoop/Hbase/Stargate)

## Contributors

*   David Worms: <https://github.com/wdavidw>
*   Michael Kurze: <https://github.com/michaelku>
*   Michal Taborsky: <https://github.com/whizz>
*   Pierre Sauvage: <https://github.com/Pierrotws>

[ryba]: https://github.com/ryba-io/ryba
[scanner]: https://github.com/adaltas/node-hbase/blob/master/test/scanner.coffee
[mt_samples]: https://gist.github.com/3979381
[mt_home]: https://github.com/stelcheck
[krb5]: https://github.com/adaltas/node-krb5
