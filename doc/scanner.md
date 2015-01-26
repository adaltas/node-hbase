---
title: "Scanner operations"
date: 2015-01-26T22:21:40.052Z
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
var myScanner = hbase({}).getTable('my_table').scan(...);
```

Or

```javascript
var client = new hbase.Client({});
var myScanner = new hbase.Scanner(client, {table: 'my_table'});
```

Options
-------



All options except the "table" option are optional. The following properties are
available:

*   `startRow`: First row returned by the scanner.   
*   `endRow`: Row stopping the scanner, not returned by the scanner.   
*   `columns`: Filter the scanner by columns (a string or an array of columns).   
*   `batch`: Number of cells returned on each iteration.   
*   `maxVersions`
*   `startTime`   
*   `endTime`   
*   `filter`: see below for more informations.   
*   `encoding`: default to client.options.encoding, set overwrite default encoding and return a buffer.   

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
client.getTable('my_tb').scan({
  filter: {
  "op":"MUST_PASS_ALL","type":"FilterList","filters":[{

```javascript
  "op":"EQUAL",
  "type":"RowFilter",
  "comparator":{"value":"my_key_.+","type":"RegexStringComparator"}
},{
  "op":"EQUAL",
  "type":"ValueFilter",
  "comparator":{"value":"here you are","type":"BinaryComparator"}
}

```

}, function(error, cells){
  assert.ifError(error);
});
```

<a name="Scanner.init"></a>
`Scanner.init(callback)`
-----------------------

Create a new scanner and return its ID.


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

```javascript
// do something
console.log(cells);
// call the next iteration
myScanner.get(callback)
lse{
// no more cells to iterate

```

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

```javascript
// do something
console.log(cells);
// call the next iteration
this.continue()
lse{
// no more cells to iterate
// delete the scanner
this.delete();

```

});
```

# <a name="Scanner.continue"></a>
`Scanner.continue()`
# --------------------
# ###
# Scanner::continue = ->
#   @get()

