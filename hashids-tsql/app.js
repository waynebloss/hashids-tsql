var pkg = require('./package.json');
var fs = require('fs');
var Hashids = require('hashids');
var swig = require('swig');
var app = require('commander');
var defv = {
  salt: makeSalt(),
  minHashLength: 0,
  alphabet: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
  seps: 'cfhistuCFHISTU'
};

app
  .version(pkg.version)
  .usage('[options] [file]')
  .option('-s, --salt          [value]', 'Salt. [random]', defv.salt)
  .option('-m, --minHashLength [n]', 'Minimum hash length. [' + defv.minHashLength.toString() + ']', defv.minHashLength)
  .option('-a, --alphabet      [value]', 'Alphabet. [a-z,A-Z,1-9,0]', defv.alphabet)
  .option('-e, --encodeOnly', 'Script encode function(s) only.')
  .parse(process.argv);

run();

function run() {
  var data = getHashData();
  var tplFiles = getTemplates();
  var i, output;
  for (i = 0; i < tplFiles.length; i++) {
    output = swig.renderFile(tplFiles[i], data);
    pipeWriteOrAppend(output, data, i === 0);
  }
}
/**
 * Gets the working data from a hashids.js instance, based on app options.
 */
function getHashData() {
  var hashids = new Hashids(app.salt, app.minHashLength, app.alphabet);
  var data = {
    startingAlphabet: app.alphabet,
    salt: hashids.salt,
    alphabet: hashids.alphabet,
    seps: hashids.seps,
    guards: hashids.guards,
    minHashLength: hashids.minHashLength,
    pipe: app.args.length === 0,
    fileName: ''
  };
  if (!data.pipe)
    data.fileName = app.args[0];
  return data;
}
/**
 * Get the templates that should be rendered based on app options.
 */
function getTemplates() {
  if (app.encodeOnly)
    return [
      './templates/tsql/encodeId.swig'
    ];
  return [
    './templates/tsql/consistentShuffle.swig',
    './templates/tsql/hash.swig',
    './templates/tsql/encodeId.swig'
  ];
}
/**
 * Pipes to stdout or writes (or appends) to a file based on the given options.
 */
function pipeWriteOrAppend(output, opt, isFirstOutput) {
  if (opt.pipe)
    console.log(output);  // CONSIDER: Is this the best way to pipe to stdout?
  else if (isFirstOutput)
    fs.writeFileSync(opt.fileName, output);
  else
    fs.appendFileSync(opt.fileName, output);
}
/**
 * Creates a new random salt value.
 */
function makeSalt() {
  var hrtime = process.hrtime(),
      value = hrtime[0] + process.pid + hrtime[1] + parseInt(Math.random(), 10),
      salt = 'D38298C1a5354BFA859f1FD2E0Fd3774',
      hashids = new Hashids(salt, 12),
      salt = hashids.encode(value);
  return salt;
}