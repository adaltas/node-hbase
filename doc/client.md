---
title: "Client: server information and object factory"
date: 2015-01-26T22:21:40.052Z
language: en
layout: page
comments: false
sharing: false
footer: false
navigation: hbase
github: https://github.com/wdavidw/node-hbase
---

Creating a new client
---------------------

A new instance of "HBase" may be instantiated with an object containing the following properties:   

-   *host*

```javascript
string, optional, default to "localhost"
Domain or IP of the HBase Stargate server
```

-   *port*

```javascript
string or int, optional, default to "8080"
Port of the HBase REST server

```

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
