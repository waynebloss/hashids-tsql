var fs = require('fs');
var Hashids = require('hashids');
var swig = require('swig');

var salt = 'CE6E160F053C41518582EA36CE9383D5';
var minHashLength = 0;

var hashids = new Hashids(salt, minHashLength);

// fs.writeFileSync(filename, data, [options]);