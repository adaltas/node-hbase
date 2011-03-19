
var hbase = require('hbase'),
	fs = require('fs'),
	path = require('path'),
	assert = require('assert');

module.exports.getClient = function(callback){
	var configFile = __dirname+'/properties.json';
	path.exists(configFile,function(exists){
		var config = exists?JSON.parse(''+fs.readFileSync(configFile)):{};
		var client = hbase(config);
		var table = client.getTable('node_table');
		table.exists( function( error, exists ){
			assert.ifError(error);
			if( exists ) return callback( error, client, config );
			table.create({
				ColumnSchema: [{
					name: 'node_column_family'
				}]
			},function( error, success ){
				callback( error, client, config );
			});
		});
	});
}

