
var utils = require('./hbase-utils')
  , Table = require('./hbase-table');

var Scanner = function(hbase, table, id){
	this.hbase = hbase;
	this.table = typeof table === 'string' ? table : table.name;
	this.id = id || null;
}

//myScanner.get([options], callback)
Scanner.prototype.create = function(options,callback){
	var self = this
	  , args = Array.prototype.slice.call(arguments)
	  , key = '/'+this.table+'/scanner '
	  , options = typeof args[0] === 'object' ? args.shift() : {}
	  , callback = args.shift();
	if(options.startRow){
		options.startRow = utils.base64.encode(options.startRow);
	}
	if(options.endRow){
		options.endRow = utils.base64.encode(options.endRow);
	}
	if(options.column){
		if(typeof options.column === 'string'){
			options.column = utils.base64.encode(options.column);
		}else{
			options.column.forEach(function(column,i){
				options.column[i] = utils.base64.encode(column);
			})
		}
	}
	this.hbase.connection.put(key, options, function( error, data, response ){
		if(error) return callback.apply(self, [error, null] );
		id = /scanner\/(\w+)$/.exec(response.headers.location)[1];
		self.id = id;
		callback.apply(self, [null, id]);
	});
}

// myScanner.delete(callback)
Scanner.prototype.delete = function(callback){
	var self = this
	  , key = '/'+this.table+'/scanner/'+this.id;
	this.hbase.connection.delete(key, function( error, success ){
		callback.apply(self, [error, error? null: true]);
	});
}

// myScanner.get(callback)
Scanner.prototype.get = function(callback){
	var self = this
	  , key = '/'+this.table+'/scanner/'+this.id;
	this.hbase.connection.get(key, function(error, data, response){
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
				cells.push( data )
			})
		});
		callback.apply(self, [null, cells]);
	});
}

module.exports = Scanner;