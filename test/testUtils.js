
var utils = require('hbase').utils,
	assert = require('assert');

exports['URL build'] = function(){
	assert.strictEqual('/table/key/%C3%A91:%C3%A81,%C3%A92:%C3%A82/1285941387939?key=value',utils.url.build(['table','key'],['é1:è1','é2:è2'],[1285941387939],{key: 'value'}));
	assert.strictEqual('/table/key/cf:c/1285941387939,1285941387939?key=value',utils.url.build(['table','key'],['cf:c'],[1285941387939,1285941387939],{key: 'value'}));
	assert.strictEqual('/table/key/cf:c?key=value',utils.url.build(['table','key'],['cf:c'],null,{key: 'value'}));
	assert.strictEqual('/table/key/cf:c?key=value',utils.url.build(['table','key'],'cf:c',null,{key: 'value'}));
	assert.strictEqual('/table/key%2Fcontaining%2Fslashes/cf:c?key=value',utils.url.build(['table','key/containing/slashes'],'cf:c',null,{key: 'value'}));
	assert.strictEqual('/table/key',utils.url.build(['table','key'],null,null,{}));
	assert.strictEqual('/table/key',utils.url.build(['table','key']));
	assert.strictEqual('/table/key/c%2Ff:c,cf2,cf3',utils.url.build(['table','key'],['c/f:c','cf2','cf3']));
};
