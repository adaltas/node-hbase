
var crypto = require('crypto');
var url = require('url');

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
		build: function(path, columns, range, parameters) {
			path.unshift('') // leading slash
			path = path.map(encodeURIComponent)
			if (columns) {
				if (typeof columns === "string") columns = [columns];
				var c = columns.map(function(col){
					return col.split(':').map(encodeURIComponent).join(':')
				});
				path.push(c.join(','));
			}
			if (range) {
				var r = '';
				if (range[0] != null) r += encodeURIComponent(range[0]);
				if (range[1] != null) r += (',' + encodeURIComponent(range[1]));
				path.push(r);
			}
			parameters = parameters||{}
			return url.format({pathname: path.join('/'), query: parameters});
		}
	},
	merge: function(obj1,obj2){
		var args = Array.prototype.slice.call(arguments);
		var r = {};
		args.forEach(function(arg){
			for(var key in arg){
				r[key] = arg[key];
			}
		})
		return r;
	}
}

module.exports = utils;