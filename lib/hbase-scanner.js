
var utils = require('./hbase-utils');
var Table = require('./hbase-table');

var Scanner = function(client, table, id){
    this.client = client;
    this.table = typeof table === 'string' ? table : table.name;
    this.id = id || null;
    this.callback = null;
};

//myScanner.continue()
Scanner.prototype.continue = function(){
    this.get();
};

//myScanner.create([params], callback)
Scanner.prototype.create = function(params,callback){
    var self = this;
    var args = Array.prototype.slice.call(arguments);
    var key = '/'+this.table+'/scanner';
    var params = typeof args[0] === 'object' ? args.shift() : {};
    var callback = args.shift();
    if(params.startRow){
        params.startRow = utils.base64.encode(params.startRow);
    }
    if(params.endRow){
        params.endRow = utils.base64.encode(params.endRow);
    }
    if(params.column){
        if(typeof params.column === 'string'){
            params.column = utils.base64.encode(params.column);
        }else{
            params.column.forEach(function(column,i){
                params.column[i] = utils.base64.encode(column);
            });
        }
    }
    if(params.filter){
        var encode = function(obj){
            for(var k in obj){
                if(k === 'value' && (!obj['type'] || obj['type'] !== 'RegexStringComparator' && obj['type'] !== 'PageFilter')){
                    obj[k] = utils.base64.encode(obj[k]);
                }else if(typeof obj[k] === 'object'){
                    encode(obj[k]);
                }
            }
        }
        encode(params.filter);
        params.filter = JSON.stringify(params.filter);
    }
    this.client.connection.put(key, params, function( error, data, response ){
        if(error) return callback.apply(self, [error, null] );
        id = /scanner\/(\w+)$/.exec(response.headers.location)[1];
        self.id = id;
        callback.apply(self, [null, id]);
    });
};

// myScanner.delete(callback)
Scanner.prototype.delete = function(callback){
    var self = this;
    var key = '/'+this.table+'/scanner/'+this.id;
    this.client.connection.delete(key, function( error, success ){
        if(!callback){
            if(error){
                throw error;
            }else{
                return;
            }
        }
        callback.apply(self, [error, error? null: true]);
    });
};

// myScanner.get(callback)
Scanner.prototype.get = function(callback){
    var self = this;
    var key = '/'+this.table+'/scanner/'+this.id;
    if(callback){
        this.callback = callback;
    }else{
        callback = this.callback;
    }
    this.client.connection.get(key, function(error, data, response){
        // result is successful but the scanner is exhausted, returns HTTP 204 status (no content)
        if(response && response.statusCode === 204) return callback.apply(self, [null, null] );
        if(error) return callback.apply(self, [error, null] );
        var cells = [];
        data.Row.forEach(function(row){
            var key = utils.base64.decode(row.key);
            row.Cell.forEach(function(cell){
                var data = {};
                data.key = key;
                data.column = utils.base64.decode(cell.column);
                data.timestamp = cell.timestamp;
                data.$ = utils.base64.decode(cell.$);
                cells.push( data );
            });
        });
        callback.apply(self, [null, cells]);
    });
};

module.exports = Scanner;