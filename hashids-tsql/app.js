var Hashids = require('hashids');
var hashids = new Hashids('CE6E160F053C41518582EA36CE9383D5');

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