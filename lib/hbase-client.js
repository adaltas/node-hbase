
var Connection = require('./hbase-connection')
  , Table = require('./hbase-table')
  , Row = require('./hbase-row')
  , Scanner = require('./hbase-scanner');

var Client = function(options){
	if(!options) options = {};
	if(!options.host) options.host = '127.0.0.1';
	if(!options.port) options.port = '8080';
	this.options = options;
	this.connection = new Connection(this);
}

Client.prototype.getVersion = function(callback){
	this.connection.get('/version', callback);
}

Client.prototype.getVersionCluster = function(callback){
	this.connection.get('/version/cluster', callback);
}

Client.prototype.getStatusCluster = function(callback){
	this.connection.get('/status/cluster', callback);
}

Client.prototype.getTables = function(callback){
	this.connection.get('/',function(err,data){
		callback( err, data && data.table ? data.table : null );
	});
}

Client.prototype.getTable = function(name){
	return new Table(this, name);
}

Client.prototype.getRow = function(table, row){
	return new Row(this, table, row);
}

Client.prototype.getScanner = function(table, id){
	return new Scanner(this, table, id);
}

module.exports = Client;