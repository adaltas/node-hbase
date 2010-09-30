
var crypto = require('crypto')
  , Table = require('./hbase-table');

var Row = function(hbase, table, key){
	this.hbase = hbase;
	this.table = typeof table === 'string' ? table : table.name;
	this.table = table;
	this.key = key;
}

//myRow.get([callback])
//Row.prototype.get = function(data, callback){
//	var self = this;
//	data.name = this.name;
//	this.hbase.connection.put( '/'+this.name+'/schema', data, function( error, data ){
//		if(!callback) return;
//		callback.apply(
//			self
//		  , [ error, error ? null : true ] )
//	});
//}

var encode = function(string){
	return (new Buffer(string, 'utf8')).toString('base64');
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