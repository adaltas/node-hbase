
var utils = require('./hbase-utils')
  , Table = require('./hbase-table');

var Row = function(client, table, key){
	this.client = client;
	this.table = typeof table === 'string' ? table : table.name;
	this.key = key;
}

// myRow.delete([column], [callback])
Row.prototype.delete = function(){
	var self = this
	  , args = Array.prototype.slice.call(arguments)
	  , key = '/'+this.table+'/'+this.key;
	if(typeof args[0] === 'string' || (typeof args[0] === 'object' && args[0] instanceof Array) ){
		key += '/'+args.shift();
	}
	this.client.connection.delete(utils.url.encode(key), function( error, success ){
		args[0].apply(self, [error, error? null: true]);
	},true);
}

// myRow.exists(column, [callback])
Row.prototype.exists = function(column, callback){
	var self = this
	  , args = Array.prototype.slice.call(arguments)
	  , key = '/'+this.table+'/'+this.key;
	if(typeof args[0] === 'string'){
		key += '/'+args.shift();
	}
	this.client.connection.get(utils.url.encode(key), function( error, exists ){
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

// myRow.get([column], [callback])
Row.prototype.get = function(column, callback){
	var self = this
	  , args = Array.prototype.slice.call(arguments)
	  , key = '/'+this.table+'/'+this.key
	  , isGlob = this.key.substr(-1,1)==='*'
	  , options = {};
	if(typeof args[0] === 'string' || (typeof args[0] === 'object' && args[0] instanceof Array) ){
		key += '/'+args.shift();
	}
	if(typeof args[0] === 'object'){
		options = args.shift();
	}
	if(options.start||options.end){
		key += '/';
		if(options.start){
			key += options.start;
		}
		if(options.end){
			key += ','+options.end;
		}
	}
	if(options.v){
		key += '?v='+options.v;
	}
	this.client.connection.get(utils.url.encode(key), function( error, data ){
		if(error) return args[0].apply(self, [error, null] );
		var cells = [];
		data.Row.forEach(function(row){
			var key = utils.base64.decode(row.key);
			row.Cell.forEach(function(cell){
				var data = {};
				if(isGlob){
					data.key = key;
				}
				data.column = utils.base64.decode(cell.column);
				data.timestamp = cell.timestamp;
				data.$ = utils.base64.decode(cell.$);
				cells.push( data )
			})
		});
		args[0].apply(self, [null, cells]);
	});
}

// myRow.put(column(s), value(s), [timestamp(s)], [callback])
// myRow.put(data, [callback])
Row.prototype.put = function(columns, values, callback){
	var self = this
	  , args = Array.prototype.slice.call(arguments)
	  , key = '/'+this.table+'/'+(this.key||'___false-row-key___')
	  , body;
	if(args.length>2){
		var columns = args.shift()
		  , values = args.shift()
		  , callback
		  , timestamps;
		if(typeof args[0] !== 'function'){
			timestamps = args.shift();
		}
		callback = args.shift();
		if(typeof columns === 'string'){
			columns = [columns];
			values = [values];
		}else if(columns.length !== values.length){
			throw new Error('Columns count must match values count');
		}
		body = {Row:[]};
		var bodyRow = {
			key: utils.base64.encode(self.key),
			Cell: []
		};
		columns.forEach(function(column,i){
			var bodyCell = {};
			if(timestamps){
				bodyCell.timestamp = timestamps[i];
			}
			bodyCell.column = utils.base64.encode(column);
			bodyCell.$ =  utils.base64.encode(values[i]);
			bodyRow.Cell.push(bodyCell);
		})
		body.Row.push(bodyRow);
		key += '/'+columns;
	}else{
		var data = args.shift(),
			callback = args.shift();
		body = {'Row':[]};
		var byRow = {};
		data.forEach(function(d){
			var row = d.row||self.key;
			if(!(row in byRow)){
				byRow[row] = [];
			}
			byRow[row].push(d);
		})
		for(var k in byRow){
			var rows = byRow[k];
			var bodyRow = {
				key: utils.base64.encode(k),
				Cell: []
			};
			rows.forEach(function(row){
				var bodyCell = {};
				if(row.timestamp){
					bodyCell.timestamp = ''+row.timestamp;
				}
				bodyCell.column = utils.base64.encode(row.column);
				bodyCell.$ =  utils.base64.encode(row.$);
				bodyRow.Cell.push(bodyCell);
			})
			body.Row.push(bodyRow);
		}
	}
	this.client.connection.put(utils.url.encode(key), body, function( error, data ){
		if(!callback) return;
		callback.apply(
			self
		  , [ error, error ? null : true ] )
	});
}

module.exports = Row;