
should = require 'should'
utils = require '../src/utils'

describe 'utils url', ->

  it 'encode table', ->
    utils.url.encode(table: 'table').should.eql '/table'

  it 'encode table+key', ->
    utils.url.encode(table: 'table', key: 'key').should.eql '/table/key'

  it 'encode table+key+column', ->
    utils.url.encode(table: 'table', key: 'key', columns: 'column_family').should.eql '/table/key/column_family'
    utils.url.encode(table: 'table', key: 'key', columns: {'column_family':'colum'}).should.eql '/table/key/column_family:colum'

  it 'encode table+key+column+params', ->
    utils.url.encode(table: 'table', key: 'key', columns: {'column_family':'colum'}, params: {key:'value'}).should.eql '/table/key/column_family:colum?key=value'
    utils.url.encode(table: 'table', key: 'key', columns: [['column_family','colum']], params: {key:'value'}).should.eql '/table/key/column_family:colum?key=value'
    utils.url.encode(table: 'table', key: 'key', columns: {'column_family':'colum'}, params: {key:'value'}).should.eql '/table/key/column_family:colum?key=value'
    utils.url.encode(table: 'table', key: 'key', columns: [['column_family','colum']], params: {key:'value'}).should.eql '/table/key/column_family:colum?key=value'

  it 'encode table+key+column+to', ->
    utils.url.encode(table: 'table', key: 'key', columns: {'column_family':'colum'}, end: 1285941387939).should.eql '/table/key/column_family:colum/1285941387939'
    utils.url.encode(table: 'table', key: 'key', columns: {'cf1':'c1','cf2':'c2'}, end: 1285941387939).should.eql '/table/key/cf1:c1,cf2:c2/1285941387939'
    utils.url.encode(table: 'table', key: 'key', columns: [['cf1','c1'],['cf2','c2']], end: 1285941387939).should.eql '/table/key/cf1:c1,cf2:c2/1285941387939'

  it 'encode table+key+column+start+to', ->
    utils.url.encode(table: 'table', key: 'key', columns: {'cf1':'c1','cf2':'c2'},start: 1285941387939, end: 1285942722246).should.eql '/table/key/cf1:c1,cf2:c2/1285941387939,1285942722246'
    utils.url.encode(table: 'table', key: 'key', columns: [['cf1','c1'],['cf2','c2']],start: 1285941387939, end: 1285942722246).should.eql '/table/key/cf1:c1,cf2:c2/1285941387939,1285942722246'

  it 'encode table+key+column+to+params', ->
    utils.url.encode(table: 'table', key: 'key', columns: {'cf1':'c1','cf2':'c2'}, end: 1285941387939, params: {key:'value'}).should.eql '/table/key/cf1:c1,cf2:c2/1285941387939?key=value'
    utils.url.encode(table: 'table', key: 'key', columns: [['cf1','c1'],['cf2','c2']], end: 1285941387939, params: {key:'value'}).should.eql '/table/key/cf1:c1,cf2:c2/1285941387939?key=value'
    utils.url.encode(table: 'tà:/', key: 'kê:/', columns: {'cf1é:/':'c1è:/','cf2é:/':'c2è:/'}, end: 1285941387939, params: {'kö:/':'vî:/'}).should.eql '/t%C3%A0%3A%2F/k%C3%AA%3A%2F/cf1%C3%A9%3A%2F:c1%C3%A8%3A%2F,cf2%C3%A9%3A%2F:c2%C3%A8%3A%2F/1285941387939?k%C3%B6%3A%2F=v%C3%AE%3A%2F'

