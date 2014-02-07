---
title: "Scanner operations"
date: 2014-02-07T15:26:49.061Z
language: en
layout: page
comments: false
sharing: false
footer: false
navigation: hbase
github: https://github.com/wdavidw/node-hbase
---

Scanner are the most efficient way to retrieve multiple 
rows and columns from HBase.

Grab an instance of "Scanner"
-----------------------------

```javascript
var myScanner = hbase({}).getScanner('my_table');
var myScanner = hbase({}).getScanner('my_table','my_id');
```

Or

```javascript
var myScanner = hbase({}).getTable('my_table').getScanner();
var myScanner = hbase({}).getTable('my_table').getScanner('my_id');
```

Or

```javascript
var client = new hbase.Client({});
var myScanner = new hbase.Scanner(client, 'my_table');
var myScanner = new hbase.Scanner(client, 'my_table', 'my_id');
```

Using filter
------------

Filter are defined during the scanner creation. If you
are familiar with HBase filters, it will be real easy to
use them. Note, you should not worry about encoding the
values, the library will do it for you. When you create
a new scanner, just associate the `filter` property with  
your filter object. All filters are supported.   

Many examples are available in the tests but here's one
wich returns all rows starting by "my_key_" and whose
value is "here you are".   

```javascript
myScanner.create({
  filter: {
  "op":"MUST_PASS_ALL","type":"FilterList","filters":[{
      "op":"EQUAL",
      "type":"RowFilter",
      "comparator":{"value":"my_key_.+","type":"RegexStringComparator"}
    },{
      "op":"EQUAL",
      "type":"ValueFilter",
      "comparator":{"value":"here you are","type":"BinaryComparator"}
    }
  ]}
}, function(error, cells){
  assert.ifError(error);
});
```

<a name="Scanner.create"></a>
`Scanner.create([params], callback)`
------------------------------------

Create a new scanner.

```javascript
myScanner.create([params], callback);
```

Params is an object for which all properties are optional. The
following properties are available:

-   startRow: First row returned by the scanner   
-   endRow: Row stopping the scanner, not returned by the scanner   
-   columns: Filter the scanner by columns (a string or an array of columns)   
-   batch: Number of cells returned on each iteration   
-   startTime   
-   endTime   
-   filter: see below for more informations

<a name="Scanner.get"></a>
`Scanner.get(callback)`
-----------------------

Scanning records.

```javascript
myScanner.get(callback);
```

Retrieve the next cells from HBase. The callback is required
and receive two arguments, an error object if any and a array
of cells or null if the scanner is exhausted.

The number of cells depends on the `batch` option. It is your
responsibity to call `get` as long as more cells are expected.

```javascript
var callback = function(error, cells){
  assert.ifError(error);
  if(cells){
    // do something
    console.log(cells);
    // call the next iteration
    myScanner.get(callback)
  }else{
    // no more cells to iterate
  }
};
myScanner.get(callback);
```

Note, this is not very pretty. Alternatively, you could make
use of the scanner function `continue` inside your callback
to trigger a new iteration. Here's how:
  
```javascript
myScanner.get(function(error, cells){
  assert.ifError(error);
  if(cells){
    // do something
    console.log(cells);
    // call the next iteration
    this.continue()
  }else{
    // no more cells to iterate
    // delete the scanner
    this.delete();
  }
});
```

<a name="Scanner.continue"></a>
`Scanner.continue()`
--------------------

<a name="Scanner.delete"></a>
`Scanner.delete(callback)`
--------------------------

Delete a scanner.

```javascript
myScanner.delete(callback);
```

Callback is optionnal and receive two arguments, an 
error object if any and a boolean indicating whether 
the scanner was removed or not.
