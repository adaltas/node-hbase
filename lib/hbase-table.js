
var Row = require('./hbase-row')
  , Scanner = require('./hbase-scanner');

var Table = function(client,name){
	this.client = client;
	this.name = name;
}

//myTable.create([data], [callback])
Table.prototype.create = function(data, callback){
	var self = this
	  , args = Array.prototype.slice.call(arguments)
	  , data = args.length && typeof args[0] === 'object' ? args.shift() : {}
	  , callback = args.length ? args.shift() : null;
	data.name = this.name;
	this.client.connection.put( '/'+this.name+'/schema', data, function( error, data ){
		if(!callback){
			if(error){
				throw error;
			}else{
				return;
			}
		}
		callback.apply(
			self
		  , [ error, error ? null : true ] )
	});
}

// myTable.delete([callback])
Table.prototype.delete = function(callback){
	var self = this;
	this.client.connection.delete( '/'+this.name+'/schema', function( error, data ){
		if(!callback){
			if(error){
				throw error;
			}else{
				return;
			}
		}
		callback.apply(
			self
		  , [ error, error ? null : true ] );
	});
}

//myTable.exists(callback)
Table.prototype.exists = function(callback){
	var self = this;
	this.client.connection.get( '/'+this.name+'/exists', function( error, exists ){
		if(error && error.code === 404 ){
			error = null;
			exists = false;
		}
		callback.apply(
			self
		  , [ error, error ? null : !( exists === false ) ] );
	});
}

//myTable.update(data, [callback])
Table.prototype.update = function(data, callback){
	console.warn('Mentionned on wiki doc but couldn\'t figure out how to use it.')
	var self = this;
	data.name = this.name;
	this.client.connection.post( '/'+this.name+'/schema', data, function( error, data ){
		if(!callback){
			if(error){
				throw error;
			}else{
				return;
			}
		}
		callback.apply(
			self
		  , [ error, error ? null : true ] )
	});
}

//myTable.getSchema(callback)
Table.prototype.getSchema = function(callback){
	var self = this;
	this.client.connection.get( '/'+this.name+'/schema', function( error, data ){
		callback.apply(
			self
		  , [ error, error ? null : data ] )
	});
}

//myTable.getRegions(callback)
Table.prototype.getRegions = function(callback){
	var self = this;
	this.client.connection.get( '/'+this.name+'/regions', function( error, data ){
		callback.apply(
			self
		  , [ error, error ? null : data ] )
	});
}

//myTable.getRow(key)
Table.prototype.getRow = function(key){
	return new Row(this.client, this.name, key);
}

//myTable.getScanner(key)
Table.prototype.getScanner = function(id){
	return new Scanner(this.client, this.name, id);
}

module.exports = Table;