
var HBase = require('hbase').HBase,
	Table = require('hbase').Table,
	fs = require('fs'),
	path = require('path');

module.exports.getHBase = function(callback){
	var configFile = __dirname+'/properties.json';
	path.exists(configFile,function(exists){
		var config = exists?JSON.parse(''+fs.readFileSync(configFile)):{};
		var hbase = new HBase(config);
		var table = hbase.getTable('node_hbase');
		table.exists( function( error, exists ){
			if( error ) return callback( error );
			if( exists ) return callback( error, hbase, config );
			table.create({
				columns: [{
					name: 'column_test'
				}]
			},function( error, success ){
				callback( error, hbase, config );
			});
		});
		
	});
}

