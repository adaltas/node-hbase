
module.exports = function(config){
    return new Client(config);
};
var Client = module.exports.Client = require('./hbase-client');
module.exports.Connection = require('./hbase-connection');
module.exports.Table = require('./hbase-table');
module.exports.Row = require('./hbase-row');
module.exports.Scanner = require('./hbase-scanner');
module.exports.utils = require('./hbase-utils');