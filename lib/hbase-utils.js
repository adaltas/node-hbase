
var crypto = require('crypto');

var utils = {
	encode: function(string){
		return (new Buffer(string, 'utf8')).toString('base64');
	},
	decode: function(string){
		return (new Buffer(string, 'base64')).toString('utf8');
	}
}

module.exports = utils;