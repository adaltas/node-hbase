
# Connection: HTTP REST requests for HBase

The connection object handles HTTP requests. You shouldn't
have to call it directly because HBase requests are transparently
made by the client objects.

Note, at this point, the HTTP client only communicate to
HBase with the JSON format. Some valid requests requests return
an empty body which of course not a valid JSON. In such cases,
no error is thrown by the response handler but the returned value
is null.

## Dependencies

    http = 
      http: require 'http'
      https: require 'https'
    url = require 'url'
    try krb5 = require 'krb5' catch # No Kerberos Support

## Creating a new connection

The most common way of initializing a new connection object
is through the client object. When a new client is constructed,
it create and hold a connection object.

```javascript
var client = hbase({ options });
assert.ok(client.connection instanceof hbase.Connection);
```

You can also manually contruct a new instance as follow:

```javascript
var connection = new hbase.Connection( client );
```

    Connection = (client) ->
      @client = client
      @

    Connection::makeRequest = (method, command, data, callback) ->
      options =
        protocol: "#{@client.options.protocol}:"
        port: @client.options.port
        hostname: @client.options.host
        method: method
        path: command
        headers:
          'content-type': 'application/json'
          'Accept': 'application/json'
        rejectUnauthorized: false
      do_krb5 = =>
        return do_spnego() if @client.krb5
        return do_request() unless @client.options.krb5.principal
        @client.options.krb5.service_principal ?= "HTTP@#{options.hostname}"
        krb5 @client.options.krb5, (err, k) =>
          return callback err if err
          @client.krb5 = k
          do_spnego()
      do_spnego = =>
        @client.krb5.token (err, token) ->
          return callback err if err
          options.headers['Authorization'] = 'Negotiate ' + token
          do_request()
      do_request = =>
        req = http[@client.options.protocol].request options, (res) =>
          body = ''
          res.on 'data', (chunk) ->
            body += chunk
          res.on 'end', =>
            error = null
            try
              body = @handleJson res, body
            catch e
              body = null
              error = e
            callback error, body, res
          res.on 'close', ->
            e = new Error 'Connection closed'
            callback e, null
        req.on 'error', (err) ->
          callback err
        if data and data isnt ''
          data = if typeof data is 'string' then data else JSON.stringify data
          req.write data, 'utf8'
        req.end()
      do_krb5()

## HTTP Get requests

```javascript
myConnection.get(command, callback, [status]);
```

Execute an HTTP Get request. The callback contains 3 arguments: the error object if any, the decoded response body and the Node `http.ClientResponse` object.

```javascript
(new Connection({}))
.get('http://localhost:8080/', function(error, data, response){
  if(error){
    process.exit(1);
  }
  console.log('Status code: ' + response.statusCode);
  console.log('Number of tables: ' + tables.length);
});
```

    Connection::get = (command, callback) ->
      @makeRequest 'GET', command, '', callback

    Connection::put = (command, data, callback) ->
      @makeRequest 'PUT', command, data, callback

    Connection::post = (command, data, callback) ->
      @makeRequest 'POST', command, data, callback

    Connection::delete = (command, callback) ->
      @makeRequest 'DELETE', command, '', callback

    Connection::handleJson = (response, body) ->
      switch response.statusCode
        # Created
        when 201, 200 # Ok
          (if body then JSON.parse(body) else null)
        else
          e = new Error "#{response.statusCode}: #{@codes[response.statusCode]}"
          e.code = response.statusCode
          e.body = body
          throw e

    Connection::codes =
      100: 'Continue'
      101: 'Switching Protocols'
      102: 'Processing (WebDAV)'
      200: 'OK'
      201: 'Created'
      202: 'Accepted'
      203: 'Non-Authoritative Information'
      204: 'No Content'
      205: 'Reset Content'
      206: 'Partial Content'
      207: 'Multi-Status (WebDAV)'
      300: 'Multiple Choices'
      301: 'Moved Permanently'
      302: 'Found'
      303: 'See Other'
      304: 'Not Modified'
      305: 'Use Proxy'
      306: 'Switch Proxy'
      307: 'Temporary Redirect'
      400: 'Bad Request'
      401: 'Unauthorized'
      402: 'Payment Required'
      403: 'Forbidden'
      404: 'Not Found'
      405: 'Method Not Allowed'
      406: 'Not Acceptable'
      407: 'Proxy Authentication Required'
      408: 'Request Timeout'
      409: 'Conflict'
      410: 'Gone'
      411: 'Length Required'
      412: 'Precondition Failed'
      413: 'Request Entity Too Large'
      414: 'Request-URI Too Long'
      415: 'Unsupported Media Type'
      416: 'Requested Range Not Satisfiable'
      417: 'Expectation Failed'
      418: 'I\'m a teapot'
      422: 'Unprocessable Entity (WebDAV)'
      423: 'Locked (WebDAV)'
      424: 'Failed Dependency (WebDAV)'
      425: 'Unordered Collection'
      426: 'Upgrade Required'
      449: 'Retry With'
      500: 'Internal Server Error'
      501: 'Not Implemented'
      502: 'Bad Gateway'
      503: 'Service Unavailable'
      504: 'Gateway Timeout'
      505: 'HTTP Version Not Supported'
      506: 'Variant Also Negotiates'
      507: 'Insufficient Storage (WebDAV)'
      509: 'Bandwidth Limit Exceeded (Apache bw/limited extension)'
      510: 'Not Extended'

    module.exports = Connection
