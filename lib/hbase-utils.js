
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
		regexp: /^\/([^\/]+)(\/?([^\/]+))?(\/?([^\/\?]+))?(\/?([\d]+,?[\d]+[^\/\?]))?(\??([^\/]+))?/,
		encode: function(path){
			var newpath = '';
			this.regexp.exec(path)
			.filter(function(path,i,a){
				return i%2===1;
			})
			.map(function(path,i,a){
				if(!path) return;
				if(i===2){
					var columns = path.split(',');
					columns.forEach(function(column,i){
						var colonPosition = column.indexOf(':');
						if(colonPosition!==-1){
							newpath += (i===0?'/':',')+encodeURIComponent(column.substr(0,colonPosition));
							newpath += ':'+encodeURIComponent(column.substr(colonPosition+1));
						}else{
							newpath += (i===0?'/':',')+encodeURIComponent(column);
						}
					})
				}else if(i===3){
					newpath += '/'+path;
				}else if(i===a.length-1){
					newpath += '?'+path;
				}else{
					newpath += '/'+encodeURIComponent(path);
				}
				return path;
			});
			return newpath;
		}
	},
	merge: function(obj1,obj2){
		var r = {};
		for(var key in obj1){
			r[key] = obj1[key];
		}
		for(var key in obj2){
			r[key] = obj2[key];
		}
		return r;
	}
}

module.exports = utils;