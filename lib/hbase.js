
var Connection = require('./hbase-connection')
  , Table = require('./hbase-table')
  , Row = require('./hbase-row')
  , Scanner = require('./hbase-scanner')
  , utils = require('./hbase-utils');

var HBase = function(config){
	if(!config) config = {};
	config.secure = !!config.secure;
	if(!config.host) config.host = '127.0.0.1';
	if(!config.port) config.port = '8080';
	this.config = config;
	this.connection = new Connection(this);
}

HBase.prototype.getVersion = function(callback){
	this.connection.get('/version', callback);
}

HBase.prototype.getVersionCluster = function(callback){
	this.connection.get('/version/cluster', callback);
}

HBase.prototype.getStatusCluster = function(callback){
	this.connection.get('/status/cluster', callback);
}

HBase.prototype.getTables = function(callback){
	this.connection.get('/',function(err,data){
		callback( err, data && data.table ? data.table : null );
	});
}

HBase.prototype.getTable = function(name){
	return new Table(this, name);
}

HBase.prototype.getRow = function(table, row){
	return new Row(this, table, row);
}

HBase.prototype.getScanner = function(table, id){
	return new Scanner(this, table, id);
}

var hbase = function(config){
	return new HBase(config);
}
hbase.HBase = HBase;
hbase.Connection = Connection;
hbase.Table = Table;
hbase.Row = Row;
hbase.Scanner = Scanner;
hbase.utils = utils;

module.exports = hbase;