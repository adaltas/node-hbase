
var Table = function(hbase,name){
	this.hbase = hbase;
	this.name = name;
}

//myTable.create([callback])
Table.prototype.create = function(data,callback){
	var self = this;
	data.name = this.name
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
		  , [ error, error ? null : true ] )
	});
}

//myTable.exists(callback)
Table.prototype.exists = function(callback){
	var self = this;
	this.hbase.getTables( function( error, tables ){
		if( error ) return callback.apply( self, [ error, null ] );
		callback.apply(
			self
		  , [ null, !!tables.filter( function(table){ return table.name === self.name } ).length ] )
	} )
}

module.exports = Table;