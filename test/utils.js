
var HBase = require('hbase').HBase,
	Table = require('hbase').Table,
	fs = require('fs'),
	path = require('path'),
	assert = require('assert');

module.exports.getHBase = function(callback){
	var configFile = __dirname+'/properties.json';
	path.exists(configFile,function(exists){
		var config = exists?JSON.parse(''+fs.readFileSync(configFile)):{};
		var hbase = new HBase(config);
		var table = hbase.getTable('node_table');
		table.exists( function( error, exists ){
			assert.ifError(error);
			if( exists ) return callback( error, hbase, config );
			table.create({
				ColumnSchema: [{
					name: 'node_column_family'
				}]
			},function( error, success ){
				callback( error, hbase, config );
			});
		});
	});
}

