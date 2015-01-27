
<pre style="font-family:courier">
 ___   _           _          _     _ ______                   
|   \ | |         | |        | |   | |____  \                  
| |\ \| | ___   __| |_____   | |___| |____)  )_____  ___ _____ 
| | \   |/ _ \ / _  | ___ |  |  ___  |  __  ((____ |/___) ___ |
| |  \  | |_| ( |_| | ____|  | |   | | |__)  ) ___ |___ | ____|
|_|   |_|\___/ \____|_____)  |_|   |_|______/\_____(___/|_____) New BSD License
</pre>

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

## Installing

Via [npm](http://github.com/isaacs/npm):

```bash
npm install hbase
```

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
  .getRow('my_row')
  .put('my_column_family:my_column', 'my value', function(err, success){
    this.get('my_column_family', function(err, cells){
      this.exists(function(err, exists){
        assert.ok(exists);
      });
    });
  });
});
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
with a scanner request. [Marc Trudel](https://github.com/stelcheck) has 
published a few examples [here](https://gist.github.com/3979381). 

## Running the tests

Tests are executed with mocha. Before running the tests the first time, copy the
file "./test/properties.json.sample" to "./test/properties.json" and make the
appropriate changes.

If using the HDP sandbox, start the virtual machine, log-in as "root", start
Ambari `start_ambari.sh`, start HBase `start_hbase.sh` and start the HBase REST
server `/usr/lib/hbase/bin/hbase rest -p 60080`.

To run the tests:

```bash
make test
```

## Related projects

*   [Official Apache HBase project](http://hbase.apache.org)
*   [REST server bundled with HBase (Stargate)](https://wiki.apache.org/hadoop/Hbase/Stargate)

## Contributors

*   David Worms: <https://github.com/wdavidw>
*   Michael Kurze: <https://github.com/michaelku>
*   Michal Taborsky: <https://github.com/whizz>
