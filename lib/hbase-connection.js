
var http = require('http');

var Connection = function(client){
    this.client = client;
};

Connection.prototype.makeRequest = function(method, command, data, callback) {
    var self = this;
	var options = {
    		port: this.client.options.port,
    		host: this.client.options.host,
    		method: method,
    		path: command,
    		headers: {
    			'content-type':'application/json',
    	        'Accept': 'application/json' 
    	    }
    };
    var req = http.request(options, function(res) {
    	var body = '';
    	res.on('data', function(chunk) {
            body += chunk;
        });
        res.on('end', function() {
            var error = null;
            try{
                body = self.handleJson(res,body);
            }catch(e){
                body = null;
                error = e;
            }
            callback(error, body, res);
        });
        res.on('close', function() {
        	var e = new Error('Connectino closed');
            callback(e,null);
        });
    });
    req.on('error', function(err){
        callback(err);
    });
    if (data && data != '') {
    	data = typeof data === 'string' ? data : JSON.stringify(data);
    	req.write(data, 'utf8');
    }
    req.end();
};

Connection.prototype.get = function(command,callback){
    this.makeRequest('GET', command, '', callback);
};

Connection.prototype.put = function(command,data,callback){
	this.makeRequest('PUT', command, data, callback);
};

Connection.prototype.post = function(command,data,callback){
	this.makeRequest('POST', command, data, callback);
};

Connection.prototype.delete = function(command,callback){
    this.makeRequest('DELETE', command, '', callback);
};

Connection.prototype.handleJson = function(response,body){
    switch(response.statusCode){
        case 201: // Created
        case 200: // Ok
            return body?JSON.parse(body):null;
        default:
            var e = new Error(response.statusCode+': '+this.codes[response.statusCode]);
            e.code = response.statusCode;
            e.body = body;
            throw e;
    }
};

Connection.prototype.codes = {
    100: 'Continue',
    101: 'Switching Protocols',
    102: 'Processing (WebDAV)',
    200: 'OK',
    201: 'Created',
    202: 'Accepted',
    203: 'Non-Authoritative Information',
    204: 'No Content',
    205: 'Reset Content',
    206: 'Partial Content',
    207: 'Multi-Status (WebDAV)',
    300: 'Multiple Choices',
    301: 'Moved Permanently',
    302: 'Found',
    303: 'See Other',
    304: 'Not Modified',
    305: 'Use Proxy',
    306: 'Switch Proxy',
    307: 'Temporary Redirect',
    400: 'Bad Request',
    401: 'Unauthorized',
    402: 'Payment Required',
    403: 'Forbidden',
    404: 'Not Found',
    405: 'Method Not Allowed',
    406: 'Not Acceptable',
    407: 'Proxy Authentication Required',
    408: 'Request Timeout',
    409: 'Conflict',
    410: 'Gone',
    411: 'Length Required',
    412: 'Precondition Failed',
    413: 'Request Entity Too Large',
    414: 'Request-URI Too Long',
    415: 'Unsupported Media Type',
    416: 'Requested Range Not Satisfiable',
    417: 'Expectation Failed',
    418: 'I\'m a teapot',
    422: 'Unprocessable Entity (WebDAV)',
    423: 'Locked (WebDAV)',
    424: 'Failed Dependency (WebDAV)',
    425: 'Unordered Collection',
    426: 'Upgrade Required',
    449: 'Retry With',
    500: 'Internal Server Error',
    501: 'Not Implemented',
    502: 'Bad Gateway',
    503: 'Service Unavailable',
    504: 'Gateway Timeout',
    505: 'HTTP Version Not Supported',
    506: 'Variant Also Negotiates',
    507: 'Insufficient Storage (WebDAV)',
    509: 'Bandwidth Limit Exceeded (Apache bw/limited extension)',
    510: 'Not Extended'
};

module.exports = Connection;