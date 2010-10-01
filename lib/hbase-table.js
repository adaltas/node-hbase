
var Row = require('./hbase-row');

var Table = function(hbase,name){
	this.hbase = hbase;
	this.name = name;
}

//myTable.create(data, [callback])
Table.prototype.create = function(data, callback){
	var self = this;
	data.name = this.name;
	this.hbase.connection.put( '/'+this.name+'/schema', data, function( error, data ){
		if(!callback) return;
		callback.apply(
			self
		  , [ error, error ? null : true ] )
	});
}

// myTable.delete([callback])
Table.prototype.delete = function(callback){
	var self = this;
	this.hbase.connection.delete( '/'+this.name+'/schema', function( error, data ){
		if(!callback) return;
		callback.apply(
			self
		  , [ error, error ? null : true ] );
	});
}

//myTable.exists(callback)
Table.prototype.exists = function(callback){
	var self = this;
	this.hbase.connection.get( '/'+this.name+'/exists', function( error, exists ){
		if(error && error.code === 404 ){
			error = null;
			exists = false;
		}
		callback.apply(
			self
		  , [ error, error ? null : ( exists === false ? false : true ) ] );
	});
}

//myTable.update(data, [callback])
Table.prototype.update = function(data, callback){
	console.warn('Mentionned on wiki doc but couldn\'t figure out how to use it.')
	var self = this;
	data.name = this.name;
	this.hbase.connection.post( '/'+this.name+'/schema', data, function( error, data ){
		if(!callback) return;
		callback.apply(
			self
		  , [ error, error ? null : true ] )
	});
}

//myTable.getSchema(callback)
Table.prototype.getSchema = function(callback){
	var self = this;
	this.hbase.connection.get( '/'+this.name+'/schema', function( error, data ){
		callback.apply(
			self
		  , [ error, error ? null : data ] )
	});
}

//myTable.getRegions(callback)
Table.prototype.getRegions = function(callback){
	var self = this;
	this.hbase.connection.get( '/'+this.name+'/regions', function( error, data ){
		callback.apply(
			self
		  , [ error, error ? null : data ] )
	});
}

//myTable.getRow(key)
Table.prototype.getRow = function(key){
	return new Row(this.hbase, this.name, key);
}

module.exports = Table;