
var http = require('http');

function createRequest(method,options, command){
	var client = http.createClient(options.port,options.host);
	var request = client.request(method, command, {
		host: options.host,
		'content-type':'application/json',
		'Accept': 'application/json'
	});
	request.socket.setTimeout(options.timeout);
	request.socket.addListener("timeout", function() {
		request.socket.destroy();
		var e = new Error('408: Client Request Timeout');
		e.code = 408;
		e.body = 'Client Request Timeout';
		throw e;
	});
	return request;
}

var Connection = function(client){
	this.client = client;
}

Connection.prototype.get = function(command,callback){
	var self = this;
	var request = createRequest('GET', this.client.options, command);
	request.end();
	request.on('response',function(response){
	    var body = '';
		response.on('data', function(chunk) {
			body += chunk;
		});
		response.on('end', function() {
			try{
				body = self.handleJson(response,body);
				var error = null;
			}catch(e){
				body = null;
				var error = e;
			}
			callback(error, body, response);
		});
		response.on('error', function(error) {
			callback(error,null);
		});
	});
};

Connection.prototype.put = function(command,data,callback){
	var self = this;
	var request = createRequest('PUT', this.client.options, command);
	data = typeof data === 'string' ? data : JSON.stringify(data);
	request.end(data, 'utf8');
	request.on('response',function(response){
	    var body = '';
		response.on('data', function(chunk) {
			body += chunk;
		});
		response.on('end', function() {
			try{
				body = self.handleJson(response, body);
				var error = null;
			}catch(e){
				body = null;
				var error = e;
			}
			callback(error, body, response);
		});
		response.on('error', function(error) {
			callback(error);
		});
	});
};

Connection.prototype.post = function(command,data,callback){
	var self = this;
	var request = createRequest('POST', this.client.options, command);
	data = typeof data === 'string' ? data : JSON.stringify(data);
	request.end(data, 'utf8');
	request.on('response',function(response){
	    var body = '';
		response.on('data', function(chunk) {
			body += chunk;
		});
		response.on('end', function() {
			try{
				body = self.handleJson(response, body);
				var error = null;
			}catch(e){
				body = null;
				var error = e;
			}
			callback(error, body, response);
		});
		response.on('error', function(error) {
			callback(error,null);
		});
	});
};

Connection.prototype.delete = function(command,callback){
	var self = this;
	var request = createRequest('DELETE', this.client.options, command);
	request.end();
	request.on('response',function(response){
	    var body = '';
		response.on('data', function(chunk) {
			body += chunk;
		});
		response.on('end', function() {
			try{
				body = self.handleJson(response, body);
				var error = null;
			}catch(e){
				body = null;
				var error = e;
			}
			callback(error, body, response);
		});
		response.on('error', function(error) {
			callback(error,null);
		});
	});
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
}

module.exports = Connection;