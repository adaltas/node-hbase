
var Client = require('./hbase-client')
  , Connection = require('./hbase-connection')
  , Table = require('./hbase-table')
  , Row = require('./hbase-row')
  , Scanner = require('./hbase-scanner')
  , utils = require('./hbase-utils');

var hbase = function(config){
	return new Client(config);
}
hbase.Client = Client;
hbase.Connection = Connection;
hbase.Table = Table;
hbase.Row = Row;
hbase.Scanner = Scanner;
hbase.utils = utils;

module.exports = hbase;