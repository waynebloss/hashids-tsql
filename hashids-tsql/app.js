var Hashids = require('hashids');
var swig = require('swig');

var salt = 'CE6E160F053C41518582EA36CE9383D5';

var hashids = new Hashids(salt, 4);

// #region Render TSQL

//var data = {
//  salt: hashids.salt,
//  alphabet: hashids.alphabet,
//  seps: hashids.seps,
//  guards: hashids.guards
//};

//swig.renderFile('./templates/tsql/encodeId.swig', data, function(err, output) {
//  if (err)
//    throw err;
//  console.log(output);
//});

// #endregion

// #region Setup

//var key, value;
//for (key in hashids) {
//  value = hashids[key];
//  if (typeof value !== 'function')
//    console.log(key + ': ' + value);
//}
//value = hashids.consistentShuffle('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890', 'CE6E160F053C41518582EA36CE9383D5');
//console.log('shuffled alphabet: ' + value);
/*
version: 1.0.1
minAlphabetLength: 16
sepDiv: 3.5
guardDiv: 12
errorAlphabetLength: error: alphabet must contain at least X unique characters
errorAlphabetSpace: error: alphabet cannot contain spaces
alphabet: NxBvP0nK7QgWmejLzwdA6apRV25lkOqo8MX1ZrbyGDE3
seps: CuHciSFTtIfUhs
minHashLength: 0
salt: CE6E160F053C41518582EA36CE9383D5
guards: 49JY
shuffled alphabet: gGW9SqRvLh7NfuHdKi5XlCjpTo2Zs1JnM40wcIVQ3e8xzOaYUFBE6bryDtPkAm
*/

// #endregion

// #region Hash

//var testHashResult = hashids.hash(1, 'NxBvP0nK7QgWmejLzwdA6apRV25lkOqo8MX1ZrbyGDE3');
//console.log('testHashResult: ' + testHashResult.toString());
/*
testHashResult: x
*/

// #endregion

// #region Basic functionality

var i, id, numbers = [1, 2, 3];

for (i = 0; i < numbers.length; i++) {
  id = hashids.encode(numbers[i]);
  console.log(id);
}
/*
xm
BQ
vn
*/

//var id, numbers;
//id = hashids.encode(1, 2, 3);
//console.log(id);
//numbers = hashids.decode(id);
//console.log(numbers);
/*
nBueHb
[ 1, 2, 3 ]
*/

// #endregion