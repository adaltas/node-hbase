'use strict'

const assert = require('assert');
const utils = require('./../lib/utils');

describe('Util', function() {
    let encoded;
    const teststring = 'row key';
    const testnumber = 1234; 
    const testdate = Date(2015,12,12);
    const encode_to = 'base64'; // Undefined and utf8 doesn't work'

  before('encode', function() {
    encoded = [
        utils.base64.encode(teststring, encode_to), 
        utils.base64.encode(testnumber, encode_to),
        utils.base64.encode(testdate, encode_to)
    ];
  });
  it('should encode and decode back', function() {
      assert.equal(utils.base64.decode(encoded[0], encode_to), teststring);
      assert.equal(utils.base64.decode(encoded[1], encode_to), testnumber);
      assert.equal(utils.base64.decode(encoded[2], encode_to), testdate);
    });
});