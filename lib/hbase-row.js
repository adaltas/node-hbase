
var utils = require('./hbase-utils')
  , Table = require('./hbase-table');

var Row = function(client, table, key){
    this.client = client;
    this.table = typeof table === 'string' ? table : table.name;
    this.key = key;
};

// myRow.delete([column], [callback])
Row.prototype.delete = function(){
    var self = this;
    var args = Array.prototype.slice.call(arguments)
    var columns;
    if(typeof args[0] === 'string' || (typeof args[0] === 'object' && args[0] instanceof Array) ){
        columns = args.shift();
    }
    var url = utils.url.encode(this.table, this.key, columns);
    this.client.connection.delete(url, function( error, success ){
        args[0].apply(self, [error, error? null: true]);
    },true);
};

// myRow.exists(column, [callback])
Row.prototype.exists = function(column, callback){
    var self = this
    var args = Array.prototype.slice.call(arguments)
    var column = typeof args[0] === 'string' ? args.shift() : null;
    var url = utils.url.encode(this.table, this.key, column);
    this.client.connection.get(url, function( error, exists ){
        // note:
        // if row does not exists: 404
        // if row exists and column family does not exists: 503
        if(error && ( error.code === 404 || error.code === 503 ) ){
            error = null;
            exists = false;
        }
        args[0].apply(self, [ error, error ? null : ( exists === false ? false : true ) ] );
    });
};

// myRow.get([column], [callback])
Row.prototype.get = function(column, callback){
    var self = this;
    var args = Array.prototype.slice.call(arguments);
    var key = '/'+this.table+'/'+this.key;
    var isGlob = this.key.substr(-1,1)==='*';
    var options = {};
    var columns = null;
    var start = null;
    var end = null;
    var params = {};
    if(typeof args[0] === 'string' || (typeof args[0] === 'object' && args[0] instanceof Array) ){
        columns = args.shift();
    }
    if(typeof args[0] === 'object'){
        options = args.shift();
    }
    if(options.start){
        start = options.start;
    }
    if(options.end){
        end = options.end;
    }
    if(options.v){
        params.v = options.v;
    }
    var url = utils.url.encode(this.table,this.key, columns, start, end, params);
    this.client.connection.get(url, function( error, data ){
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
                cells.push( data );
            });
        });
        args[0].apply(self, [null, cells]);
    });
};

// myRow.put(column(s), value(s), [timestamp(s)], [callback])
// myRow.put(data, [callback])
Row.prototype.put = function(columns, values, callback){
    var self = this;
    var args = Array.prototype.slice.call(arguments);
    var url;
    var body;
    var bodyRow;
    if(args.length>2){
        columns = args.shift();
        values = args.shift();
        var timestamps;
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
        bodyRow = {
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
        });
        body.Row.push(bodyRow);
        url = utils.url.encode(this.table,this.key||'___false-row-key___',columns);
    }else{
        var data = args.shift();
        callback = args.shift();
        body = {'Row':[]};
        var cellsKeys = {};
        data.forEach(function(d){
            var key = d.key||self.key;
            if(!(key in cellsKeys)){
                cellsKeys[key] = [];
            }
            cellsKeys[key].push(d);
        });
        for(var k in cellsKeys){
            var cells = cellsKeys[k];
            bodyRow = {
                key: utils.base64.encode(k),
                Cell: []
            };
            for(var k1 in cells){
                var cell = cells[k1];
                var bodyCell = {};
                if(cell.timestamp){
                    bodyCell.timestamp = ''+cell.timestamp;
                }
                bodyCell.column = utils.base64.encode(cell.column);
                bodyCell.$ =  utils.base64.encode(cell.$);
                bodyRow.Cell.push(bodyCell);
            }
            body.Row.push(bodyRow);
        }
        url = utils.url.encode(this.table, this.key || '___false-row-key___');
    }
    this.client.connection.put(url, body, function( error, data ){
        if(!callback) return;
        callback.apply(self, [ error, error ? null : true ] );
    });
};

module.exports = Row;