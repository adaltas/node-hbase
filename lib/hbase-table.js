
var Row = require('./hbase-row');
var Scanner = require('./hbase-scanner');

var Table = function(client,name){
    this.client = client;
    this.name = name;
};

//myTable.create([schema], [callback])
Table.prototype.create = function(schema, callback){
    var self = this;
    var args = Array.prototype.slice.call(arguments);
    schema = args.length && typeof args[0] === 'object' || typeof args[0] === 'string' ? args.shift() : {};
    callback = args.length ? args.shift() : null;
    schema.name = this.name;
    if(typeof schema === 'string'){
        schema = {
            ColumnSchema: [{
                name: schema
            }]
        };
    }
    this.client.connection.put( '/'+this.name+'/schema', schema, function( error, data ){
        if(!callback){
            if(error){
                throw error;
            }else{
                return;
            }
        }
        callback.apply(self, [ error, error ? null : true ] );
    });
};

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
        callback.apply(self, [ error, error ? null : true ] );
    });
};

//myTable.exists(callback)
Table.prototype.exists = function(callback){
    var self = this;
    this.client.connection.get( '/'+this.name+'/exists', function( error, exists ){
        if(error && error.code === 404 ){
            error = null;
            exists = false;
        }
        callback.apply(self, [ error, error ? null : !( exists === false ) ] );
    });
};

//myTable.update(schema, [callback])
Table.prototype.update = function(schema, callback){
    var self = this;
    schema.name = this.name;
    this.client.connection.post( '/'+this.name+'/schema', schema, function( error, data ){
        if(!callback){
            if(error){
                throw error;
            }else{
                return;
            }
        }
        callback.apply(self, [ error, error ? null : true ] );
    });
};

//myTable.getSchema(callback)
Table.prototype.getSchema = function(callback){
    var self = this;
    this.client.connection.get( '/'+this.name+'/schema', function( error, data ){
        callback.apply(self, [ error, error ? null : data ] );
    });
};

//myTable.getRegions(callback)
Table.prototype.getRegions = function(callback){
    var self = this;
    this.client.connection.get( '/'+this.name+'/regions', function( error, data ){
        callback.apply(self, [ error, error ? null : data ] );
    });
};

//myTable.getRow(key)
Table.prototype.getRow = function(key){
    return new Row(this.client, this.name, key);
};

//myTable.getScanner(key)
Table.prototype.getScanner = function(id){
    return new Scanner(this.client, this.name, id);
};

module.exports = Table;