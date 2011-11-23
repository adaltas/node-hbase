
utils = require('hbase').utils
assert = require('assert')

module.exports = 
    'URL encode': (next) ->
        assert.eql('/table', utils.url.encode('table'))
        assert.eql('/table', utils.url.encode('table'))
        assert.eql('/table/key', utils.url.encode('table','key'))
        assert.eql('/table/key', utils.url.encode('table','key',null,null,null,null))
        assert.eql('/table/key/column_family', utils.url.encode('table','key','column_family'))
        assert.eql('/table/key/column_family:colum', utils.url.encode('table','key',{'column_family':'colum'}))
        assert.eql('/table/key/column_family:colum?key=value', utils.url.encode('table','key',{'column_family':'colum'},{key:'value'}))
        assert.eql('/table/key/column_family:colum?key=value', utils.url.encode('table','key',[['column_family','colum']],{key:'value'}))
        assert.eql('/table/key/column_family:colum?key=value', utils.url.encode('table','key',{'column_family':'colum'},{key:'value'}))
        assert.eql('/table/key/column_family:colum?key=value', utils.url.encode('table','key',[['column_family','colum']],{key:'value'}))
        assert.eql('/table/key/column_family:colum/1285941387939', utils.url.encode('table','key',{'column_family':'colum'},1285941387939))
        assert.eql('/table/key/cf1:c1,cf2:c2/1285941387939', utils.url.encode('table','key',{'cf1':'c1','cf2':'c2'},1285941387939))
        assert.eql('/table/key/cf1:c1,cf2:c2/1285941387939', utils.url.encode('table','key',[['cf1','c1'],['cf2','c2']],1285941387939))
        assert.eql('/table/key/cf1:c1,cf2:c2/1285941387939?key=value', utils.url.encode('table','key',{'cf1':'c1','cf2':'c2'},1285941387939,{key:'value'}))
        assert.eql('/table/key/cf1:c1,cf2:c2/1285941387939?key=value', utils.url.encode('table','key',[['cf1','c1'],['cf2','c2']],1285941387939,{key:'value'}))
        assert.eql('/table/key/cf1:c1,cf2:c2/1285941387939,1285942722246', utils.url.encode('table','key',{'cf1':'c1','cf2':'c2'},1285941387939,1285942722246))
        assert.eql('/table/key/cf1:c1,cf2:c2/1285941387939,1285942722246', utils.url.encode('table','key',[['cf1','c1'],['cf2','c2']],1285941387939,1285942722246))
        assert.eql('/t%C3%A0%3A%2F/k%C3%AA%3A%2F/cf1%C3%A9%3A%2F:c1%C3%A8%3A%2F,cf2%C3%A9%3A%2F:c2%C3%A8%3A%2F/1285941387939?k%C3%B6%3A%2F=v%C3%AE%3A%2F', utils.url.encode('tà:/','kê:/',{'cf1é:/':'c1è:/','cf2é:/':'c2è:/'},1285941387939,{'kö:/':'vî:/'}))
        next()
