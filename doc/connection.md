
# Connection: HTTP REST requests for HBase

The connection object handles HTTP requests. You shouldn't have to call it 
directly because HBase requests are transparently made by the client objects.

Note, at this point, the HTTP client only communicate to HBase with the JSON
format. Some valid requests requests return an empty body which of course not a
valid JSON. In such cases, no error is thrown by the response handler but the
returned value is null.

## Creating a new connection

The most common way of initializing a new connection object is through the
client object. When a new client is constructed, it create and hold a
connection object.

```javascript
const client = hbase({ options })
assert.ok(client.connection instanceof hbase.Connection)
```

You can also manually contruct a new instance as follow:

```javascript
const connection = new hbase.Connection( client )
```

## HTTP Get requests

```javascript
myConnection.get(command, callback, [status]);
```

Execute an HTTP Get request. The callback contains 3 arguments: the error object if any, the decoded response body and the Node `http.ClientResponse` object.

```javascript
const connection = new Connection({})
connection.get('http://localhost:8080/', function(error, data, response){
  if(error) process.exit(1)
  console.info('Status code: ' + response.statusCode)
  console.info('Number of tables: ' + tables.length)
})
```
