var pkg = require('./package.json');
var fs = require('fs');
var Hashids = require('hashids');
var swig = require('swig');
var app = require('commander');
var def = {
  salt: makeSalt(),
  minHashLength: 0,
  alphabet: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
  seps: 'cfhistuCFHISTU'
};

app
  .version(pkg.version)
  .usage('[options] [file]')
  .option('-s, --salt [value]', 'Salt. [random]', def.salt)
  .option('-m, --minHashLength [n]', 'Minimum hash length. [' + def.minHashLength.toString() + ']', def.minHashLength)
  .option('-a, --alphabet [value]', 'Alphabet. [a-z,A-Z,1-9,0]', def.alphabet)
  .parse(process.argv);

if (app.args.length === 0)
  app.args.push('./hashids.encodeId.sql');

run();

function run() {
  var hashids = new Hashids(app.salt, app.minHashLength, app.alphabet);
  var data = {
    salt: hashids.salt,
    alphabet: hashids.alphabet,
    seps: hashids.seps,
    guards: hashids.guards,
    minHashLength: hashids.minHashLength,
    fileName: app.args[0]
  };
  var output = swig.renderFile('./templates/tsql/encodeId.swig', data);
  fs.writeFileSync(data.fileName, output);
}

/**
 * Creates a new salt value.
 */
function makeSalt() {
  var hrtime = process.hrtime(),
      value = hrtime[0] + process.pid + hrtime[1] + parseInt(Math.random(), 10),
      salt = 'D38298C1a5354BFA859f1FD2E0Fd3774',
      hashids = new Hashids(salt, 12),
      salt = hashids.encode(value);
  return salt;
}