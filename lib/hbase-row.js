
var crypto = require('crypto')
  , Table = require('./hbase-table');


var encode = function(string){
	return (new Buffer(string, 'utf8')).toString('base64');
}

var decode = function(string){
	return (new Buffer(string, 'base64')).toString('utf8');
}

var Row = function(hbase, table, key){
	this.hbase = hbase;
	this.table = typeof table === 'string' ? table : table.name;
	this.table = table;
	this.key = key;
}

//myRow.get([callback])
Row.prototype.get = function(column, callback){
	var self = this;
	this.hbase.connection.get('/'+this.table+'/'+this.key+'/'+column, function( error, data ){
		data = data?decode(data.Row[0].Cell[0].$):null;
		callback.apply(
			self
		  , [ error, error ? null : data ] )
	});
}

//myRow.get([callback])
Row.prototype.exists = function(column, callback){
	var self = this;
	this.hbase.connection.get('/'+this.table+'/'+this.key+'/'+column, function( error, exists ){
		// note:
		// if row does not exists: 404
		// if row exists and column family does not exists: 503
		if(error && ( error.code === 404 || error.code === 503 ) ){
			error = null;
			exists = false;
		}
		callback.apply(
			self
		  , [ error, error ? null : ( exists === false ? false : true ) ] );
	},true);
}

//myRow.put(column, value, [callback])
Row.prototype.put = function(column, data, callback){
	var self = this;
	var data = {
		'Row': [{
			'key': encode(this.key),
			'Cell': [{
				'column': encode(column),
				'$': encode(data)
			}]
		}]
	};
	this.hbase.connection.put('/'+this.table+'/'+this.key+'/'+column, data, function( error, data ){
		if(!callback) return;
		callback.apply(
			self
		  , [ error, error ? null : true ] )
	});
}

module.exports = Row;