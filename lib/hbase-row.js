
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

//myRow.delete([column], [callback])
Row.prototype.delete = function(){
	var self = this
	  , args = Array.prototype.slice.call(arguments)
	  , key = '/'+this.table+'/'+this.key;
	if(typeof args[0] === 'string'){
		key += '/'+args.shift();
	}
	this.hbase.connection.delete(key, function( error, success ){
		args[0].apply(self, [error, error? null: true]);
	},true);
}

//myRow.exists(column, [callback])
Row.prototype.exists = function(column, callback){
	var self = this
	  , args = Array.prototype.slice.call(arguments)
	  , key = '/'+this.table+'/'+this.key;
	if(typeof args[0] === 'string'){
		key += '/'+args.shift();
	}
	this.hbase.connection.get(key, function( error, exists ){
		// note:
		// if row does not exists: 404
		// if row exists and column family does not exists: 503
		if(error && ( error.code === 404 || error.code === 503 ) ){
			error = null;
			exists = false;
		}
		args[0].apply(
			self
		  , [ error, error ? null : ( exists === false ? false : true ) ] );
	},true);
}

//myRow.get([column], [callback])
Row.prototype.get = function(column, callback){
	var self = this
	  , args = Array.prototype.slice.call(arguments)
	  , key = '/'+this.table+'/'+this.key;
	if(typeof args[0] === 'string'){
		key += '/'+args.shift();
	}
	this.hbase.connection.get(key, function( error, data ){
		if(error) return args[0].apply(self, [error, null] );
		var cells = [];
		data.Row[0].Cell.forEach(function(d){
			cells.push( {column:decode(d.column), timestamp:d.timestamp, $:decode(d.$)} )
		})
		args[0].apply(self, [null, cells]);
	});
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