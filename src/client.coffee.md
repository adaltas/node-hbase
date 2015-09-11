

# Client: server information and object factory

## Dependencies

    Connection = require "./connection"
    Table = require "./table"
    Row = require "./row"
    Scanner = require "./scanner"

## Creating a new client

A new instance of "HBase" may be instantiated with an object containing the
following properties:   

*   `protocol` (string)   
    One of 'http' or 'https', default to "http".   
*   `host` (string)   
    Domain or IP of the HBase Stargate server, optional, default to "localhost".   
*   `port` (string|int)   
    Port of the HBase REST server, optional, default to "8080".   
*   `krb5` (object)   
    Configuration object for Kerberos.   
*   `krb5.principal` (string)   
    Kerberos user principal, required.   
*   `krb5.password` (string)   
    Kerberos password of the user principal, optional if using a keytab.   
*   `krb5.keytab` (string)   
    Path to the Kerberos keytab or null if using the default credential cache.   
*   `krb5.service_principal (string)   
    GSS service principal in the form of "HTTP@{fqdn}", optional, automatically
    discovered if "host" is a correct fqdn.   


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

    Client = (options) ->
      options = {}  unless options
      options.protocol ?= 'http'
      options.host ?= '127.0.0.1'
      options.port ?= '8080'
      options.krb5 ?= {}
      throw Error "Invalid protocol #{JSON.stringify options.protocol}" unless options.protocol in ['http', 'https']
      # options.timeout = 60 * 1000  unless options.timeout
      @options = options
      @connection = new Connection @
      @

## Query Software Version

```javascript
client.version( function( error, version ){
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

    Client::version = (callback) ->
      @connection.get "/version", callback

## Query Storage Cluster Version

```javascript
client.version_cluster( function( error, version ){
  console.log( version );
} );
```

Will print something similar to:

```csv
'0.89.20100726'
```

    Client::version_cluster = (callback) ->
      @connection.get "/version/cluster", callback

## Query Storage Cluster Status

```javascript
client.status_cluster( function( error, statusCluster ){
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

    Client::status_cluster = (callback) ->
      @connection.get "/status/cluster", callback

## List tables

```javascript
client.tables( function( error, tables ){
  console.log( tables );
} );
```

Will print something similar to:

```json
[ { name: 'node_hbase' } ]
```

    Client::tables = (callback) ->
      @connection.get "/", (err, data) ->
        callback err, (if data and data.table then data.table else null)


    Client::table = (name) ->
      new Table(this, name)

    module.exports = Client
