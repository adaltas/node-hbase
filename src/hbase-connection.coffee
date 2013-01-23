http = require("http")
Connection = (client) ->
  @client = client

Connection::makeRequest = (method, command, data, callback) ->
  self = this
  options =
    port: @client.options.port
    host: @client.options.host
    method: method
    path: command
    headers:
      "content-type": "application/json"
      Accept: "application/json"

  req = http.request(options, (res) ->
    body = ""
    res.on "data", (chunk) ->
      body += chunk

    res.on "end", ->
      error = null
      try
        body = self.handleJson(res, body)
      catch e
        body = null
        error = e
      callback error, body, res

    res.on "close", ->
      e = new Error("Connectino closed")
      callback e, null

  )
  req.on "error", (err) ->
    callback err

  if data and data isnt ""
    data = (if typeof data is "string" then data else JSON.stringify(data))
    req.write data, "utf8"
  req.end()

Connection::get = (command, callback) ->
  @makeRequest "GET", command, "", callback

Connection::put = (command, data, callback) ->
  @makeRequest "PUT", command, data, callback

Connection::post = (command, data, callback) ->
  @makeRequest "POST", command, data, callback

Connection::delete = (command, callback) ->
  @makeRequest "DELETE", command, "", callback

Connection::handleJson = (response, body) ->
  switch response.statusCode
    # Created
    when 201, 200 # Ok
      (if body then JSON.parse(body) else null)
    else
      e = new Error(response.statusCode + ": " + @codes[response.statusCode])
      e.code = response.statusCode
      e.body = body
      throw e

Connection::codes =
  100: "Continue"
  101: "Switching Protocols"
  102: "Processing (WebDAV)"
  200: "OK"
  201: "Created"
  202: "Accepted"
  203: "Non-Authoritative Information"
  204: "No Content"
  205: "Reset Content"
  206: "Partial Content"
  207: "Multi-Status (WebDAV)"
  300: "Multiple Choices"
  301: "Moved Permanently"
  302: "Found"
  303: "See Other"
  304: "Not Modified"
  305: "Use Proxy"
  306: "Switch Proxy"
  307: "Temporary Redirect"
  400: "Bad Request"
  401: "Unauthorized"
  402: "Payment Required"
  403: "Forbidden"
  404: "Not Found"
  405: "Method Not Allowed"
  406: "Not Acceptable"
  407: "Proxy Authentication Required"
  408: "Request Timeout"
  409: "Conflict"
  410: "Gone"
  411: "Length Required"
  412: "Precondition Failed"
  413: "Request Entity Too Large"
  414: "Request-URI Too Long"
  415: "Unsupported Media Type"
  416: "Requested Range Not Satisfiable"
  417: "Expectation Failed"
  418: "I'm a teapot"
  422: "Unprocessable Entity (WebDAV)"
  423: "Locked (WebDAV)"
  424: "Failed Dependency (WebDAV)"
  425: "Unordered Collection"
  426: "Upgrade Required"
  449: "Retry With"
  500: "Internal Server Error"
  501: "Not Implemented"
  502: "Bad Gateway"
  503: "Service Unavailable"
  504: "Gateway Timeout"
  505: "HTTP Version Not Supported"
  506: "Variant Also Negotiates"
  507: "Insufficient Storage (WebDAV)"
  509: "Bandwidth Limit Exceeded (Apache bw/limited extension)"
  510: "Not Extended"

module.exports = Connection