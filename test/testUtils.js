
var utils = require('hbase').utils;

exports['URL encode regexp'] = function(assert){
	var split = function(path){
		path = utils.url.regexp.exec(path).filter(function(path,i){
			return path&&i%2===1;
		})
		return path;
	}
	assert.deepEqual(['table'],split('/table'));
	assert.deepEqual(['table'],split('/table/'));
	assert.deepEqual(['table','key'],split('/table/key'));
	assert.deepEqual(['table','key'],split('/table/key/'));
	assert.deepEqual(['table','key','column_family'],split('/table/key/column_family'));
	assert.deepEqual(['table','key','column_family:colum'],split('/table/key/column_family:colum'));
	assert.deepEqual(['table','key','column_family:colum'],split('/table/key/column_family:colum/'));
	assert.deepEqual(['table','key','column_family:colum:test'],split('/table/key/column_family:colum:test/'));
	assert.deepEqual(['table','key','column_family:colum:test','key=value'],split('/table/key/column_family:colum:test?key=value'));
	assert.deepEqual(['table','key','column_family:colum','timestamp'],split('/table/key/column_family:colum/timestamp'));
	assert.deepEqual(['table','key','cf1:c1,cf2:c2','timestamp'],split('/table/key/cf1:c1,cf2:c2/timestamp'));
	assert.deepEqual(['table','key','column_family:colum','timestamp','key=value'],split('/table/key/column_family:colum/timestamp?key=value'));
};

exports['URL encode'] = function(assert){
	assert.strictEqual('/table/key/%C3%A91:%C3%A81,%C3%A92:%C3%A82/timestamp?key=value',utils.url.encode('/table/key/é1:è1,é2:è2/timestamp?key=value'));
	assert.strictEqual('/table/key/cf:c?key=value',utils.url.encode('/table/key/cf:c?key=value'));
};
