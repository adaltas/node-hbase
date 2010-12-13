
var utils = require('./utils')
  , assert = require('assert');

exports['Get version'] = function(){
	utils.getClient(function( error, client ){
		client.getVersion(function(err,version){
			assert.ifError(err);
			var keys = [];
			for(var key in version) keys.push(key);
			assert.deepEqual(['Server','REST','OS','Jersey','JVM'],keys);
		});
	});
};

exports['Get version cluster'] = function(){
	utils.getClient(function( error, client ){
		client.getVersionCluster(function(err,versionCluster){
			assert.ifError(err);
			assert.ok(/^(Unknown)|(\d[\d\.]+)/.test(versionCluster));
		});
	});
};

exports['Get status cluster'] = function(){
	utils.getClient(function( error, client ){
		client.getStatusCluster(function(err,statusCluster){
			assert.ifError(err);
			var keys = [];
			for(var key in statusCluster){
				keys.push(key);
			}
			assert.deepEqual(['requests','regions','averageLoad','DeadNodes','LiveNodes'],keys);
		});
	});
};

exports['Get tables'] = function(){
	utils.getClient(function( error, client ){
		client.getTables(function(err,tables){
			assert.ifError(err);
			assert.strictEqual( 1, tables.filter( function(table){ return table.name === 'node_table' } ).length );
		});
	});
};
