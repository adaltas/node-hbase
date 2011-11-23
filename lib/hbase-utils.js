
var crypto = require('crypto');

var utils = {
    base64: {
        encode: function(string){
            return (new Buffer(string, 'utf8')).toString('base64');
        },
        decode: function(string){
            return (new Buffer(string, 'base64')).toString('utf8');
        }
    },
    url: {
        encode: function(table, key, columns, from, to, params){
            var args = Array.prototype.slice.call(arguments);
            var newpath = '/';
            if(args.length > 3 && typeof args[args.length-1] === 'object'){
                params = args.pop();
            }
            // Table
            if(args.length){
                newpath += encodeURIComponent(args.shift());
            }
            // Key
            if(args.length){
                newpath += '/';
                newpath += encodeURIComponent(args.shift());
            }
            // Columns
            if(args.length){
                var columnPath;
                columns = args.shift();
                if(Array.isArray(columns)){
                    columnPath = columns.map(function(column){
                        if(Array.isArray(column)){
                            return column.map(function(c){ return encodeURIComponent(c); }).join(':');
                        }else{
                            return encodeURIComponent(column);
                        }
                    }).join(',');
                }else if(typeof columns === 'object'){
                    var cs = [];
                    for(var k in columns){
                        cs.push(encodeURIComponent(k)+':'+encodeURIComponent(columns[k]));
                    }
                    columnPath = cs.join(',');
                }else{
                    columnPath = columns ? encodeURIComponent(columns) : '';
                }
                if(columnPath){
                    newpath += '/';
                    newpath += columnPath;
                }
            }
            // From & To
            from = to = null;
            if(args.length){
                from = args.shift();
            }
            // To
            if(args.length){
                to = args.shift();
            }
            if(from || to){
                newpath += '/';
                if(from){
                    newpath += encodeURIComponent(from);
                }
                if(to){
                    newpath += ',';
                    newpath += encodeURIComponent(to);
                }
            }
            // Params
            if(params){
                newpath += '?';
                var ps = [];
                for(var k in params){
                    ps.push(encodeURIComponent(k)+'='+encodeURIComponent(params[k]));
                }
                newpath += ps.join(',');
            }
            return newpath;
        }
    }
};

module.exports = utils;