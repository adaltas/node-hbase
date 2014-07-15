var test = require('./test'),
cells = [],
time = Date.now(),
rowKey = 'test_get_columns',
dataA = [
         {col:'a1',val:'v1a'},
         {col:'a2',val:'v2a'}];
dataB = [
         {col:'a1',val:'v1b'}, // alter a1 'v1a' -> 'v1b' 
         {col:'b2',val:'v2b'}];

function dataEntry(entry, ts) {
  console.log('de', arguments);
  var cell = {
    column: 'node_column_family:' + entry.col,
    $: entry.val.toString()
  };
  if (ts) {
    cell.timestamp = ts;
  }
  cells.push(cell);
};

// earlyer data
for (var cf in dataA) {
  dataEntry(dataA[cf], time - 100);
}
// newer data
for (var cf in dataB) {
  dataEntry(dataB[cf], time);
}

test.getClient(function(err, client) {
  client.getRow('node_table', rowKey).put(cells, function(err, data, cfg) {
    console.log('###', cells);
    console.log(arguments);
    console.log('###');
    if(err) {
       throw err;
    }
    
    client.getRow('node_table', rowKey).get(function(err, cells) {
      console.log('== 1 == ',arguments);
//    cells should be [ 
//    {column:'node_column_family:a2',$:'v2a',timestamp: time-100},
//    {column:'node_column_family:a1',$:'v1b',timestamp: time},
//    {column:'node_column_family:b2',$:'v2b',timestamp: time}]
    });

    client.getRow('node_table', rowKey).get('node_column_family:a1',function(err, cells) {
      console.log('== 2 == ',arguments);
//    cells should be [ 
//    {column:'node_column_family:a1',$:'v1b',timestamp: time}]
    });

    client.getRow('node_table', rowKey).get('node_column_family:a1',{start: time-10},function(err, cells) {
      console.log('== 3 == ',arguments);
//    cells should be [ 
//    {column:'node_column_family:a1',$:'v1b',timestamp: time}]
    });

    client.getRow('node_table', rowKey).get('node_column_family:a1',{start: time-150,end:time-50},function(err, cells) {
      console.log('== 4 == ',arguments);
//    cells should be [ 
//    {column:'node_column_family:a1',$:'v1a',timestamp: time-100}]
    });

    client.getRow('node_table', rowKey).get({start: time-150,end:time-50},function(err, cells) {
      console.log('== 5 == ',arguments);
//    cells should be [ 
//    {column:'node_column_family:a1',$:'v1a',timestamp: time-100},
//    {column:'node_column_family:a2',$:'v2a',timestamp: time-100}]
    });

    client.getRow('node_table', rowKey).get({start: time-150,end:time+50},function(err, cells) {
      console.log('== 6 == ',arguments);
//    cells should be [ 
//    {column:'node_column_family:a2',$:'v2a',timestamp: time-100},
//    {column:'node_column_family:a1',$:'v1b',timestamp: time},
//    {column:'node_column_family:b2',$:'v2b',timestamp: time}]
    });

  });
  
});

