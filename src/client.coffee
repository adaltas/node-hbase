
Connection = require "./connection"
Table = require "./table"
Row = require "./row"
Scanner = require "./scanner"

###

Client: server information and object factory
=============================================

Creating a new client
---------------------

A new instance of "HBase" may be instantiated with an object containing the following properties:   

-   *host*
    string, optional, default to "localhost"
    Domain or IP of the HBase Stargate server
-   *port*
    string or int, optional, default to "8080"
    Port of the HBase REST server

Calling the `hbase` method return an initialized client object.

```javascript
var hbase = require('hbase');
var client = hbase({ options });
```

You can also manually contruct a new instance as follow:

```javascript
var hbase = require('hbase');
var client = new hbase.Client({ options });
```
###
Client = (options) ->
  options = {}  unless options
  options.host = "127.0.0.1"  unless options.host
  options.port = "8080"  unless options.port
  options.timeout = 60 * 1000  unless options.timeout
  @options = options
  @connection = new Connection @
  @

###
Query Software Version
----------------------

```javascript
client.getVersion( function( error, version ){
  console.log( version );
} );
```

Will print something similar to:

```json
{ Server: 'jetty/6.1.24'
, REST: '0.0.2'
, OS: 'Mac OS X 10.6.4 x86_64'
, Jersey: '1.1.5.1'
, JVM: 'Apple Inc. 1.6.0_20-16.3-b01-279'
}
```
###
Client::getVersion = (callback) ->
  @connection.get "/version", callback

###
Query Storage Cluster Version
-----------------------------

```javascript
client.getVersionCluster( function( error, versionCluster ){
  console.log( versionCluster );
} );
```

Will print something similar to:

```csv
'0.89.20100726'
```
###
Client::getVersionCluster = (callback) ->
  @connection.get "/version/cluster", callback

###
Query Storage Cluster Status
----------------------------

```javascript
client.getStatusCluster( function( error, statusCluster ){
  console.log( statusCluster );
} );
```

Will print something similar to:

```json
{ requests: 0
, regions: 3
, averageLoad: 3
, DeadNodes: [ null ]
, LiveNodes: [ { Node: [Object] } ]
}
```
###
Client::getStatusCluster = (callback) ->
  @connection.get "/status/cluster", callback

###
List tables
-----------

```javascript
client.getTables( function( error, tables ){
  console.log( tables );
} );
```

Will print something similar to:

```json
[ { name: 'node_hbase' } ]
```
###
Client::getTables = (callback) ->
  @connection.get "/", (err, data) ->
    callback err, (if data and data.table then data.table else null)


Client::getTable = (name) ->
  new Table(this, name)

Client::getRow = (table, row) ->
  new Row(this, table, row)

Client::getScanner = (table, id) ->
  new Scanner(this, table, id)

module.exports = Client
