
var http = require('http');

var makeUrl = function(config){
	return (config.secure?'https':'http')+'://'+config.host+(config.port?':'+config.port:'')+'/';
}

var Connection = function(hbase){
	this.hbase = hbase;
}

Connection.prototype.get = function(command,callback){
	var client = http.createClient(this.hbase.config.port,this.hbase.config.host);
	var request = client.request('GET', command, {
		host: this.hbase.config.host,
		'content-type':'application/json',
		'Accept': 'application/json'
	});
	request.end();
	request.on('response',function(response){
	    var body = '';
		response.on('data', function (chunk) {
			body += chunk;
		});
		response.on('end', function (chunk) {
//			console.log(body);
			callback(null,JSON.parse(body));
		});
		response.on('error', function (error) {
			callback(error,null);
		});
	});
};

Connection.prototype.put = function(command,data,callback){
	var client = http.createClient(this.hbase.config.port,this.hbase.config.host);
	var request = client.request('PUT', command, {
		host: this.hbase.config.host,
		'content-type':'application/json',
		'Accept': 'application/json'
	});
	request.end(JSON.stringify(data),'utf8');
	request.on('response',function(response){
	    var body = '';
		response.on('data', function (chunk) {
			body += chunk;
		});
		response.on('end', function (chunk) {
			callback(null,JSON.body?parse(body):null);
		});
		response.on('error', function (error) {
			callback(error,null);
		});
	});
};

Connection.prototype.delete = function(command,callback){
	var client = http.createClient(this.hbase.config.port,this.hbase.config.host);
	var request = client.request('DELETE', command, {
		host: this.hbase.config.host,
		'content-type':'application/json',
		'Accept': 'application/json'
	});
	request.end();
	request.on('response',function(response){
	    var body = '';
		response.on('data', function (chunk) {
			body += chunk;
		});
		response.on('end', function (chunk) {
			callback(null,JSON.body?parse(body):null);
		});
		response.on('error', function (error) {
			callback(error,null);
		});
	});
};

module.exports = Connection;