'use strict';

var pkg = require('./package.json');
var fs = require('fs');
var path = require('path');
var Hashids = require('hashids');
var swig = require('swig');
var app = require('commander');
var defv = {
  salt: makeSalt(),
  minHashLength: 0,
  alphabet: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
  seps: 'cfhistuCFHISTU',
  fileExt: 'sql',
  schema: 'hashids'
};

app
  .version(pkg.version)
  .usage('[options] [file path or directory/ path]')
  .option('-d, --database [name]', 'Database name.')
  .option('-n, --schema [name]', 'Database schema [hashids].', 'hashids')
  .option('-s, --salt [value]', 'Salt. [random]', defv.salt)
  .option('-l, --minHashLength [n]', 'Minimum hash length. [' + defv.minHashLength.toString() + ']', defv.minHashLength)
  .option('-a, --alphabet [value]', 'Alphabet. [a-z,A-Z,1-9,0]', defv.alphabet)
  .option('-e, --encodeOnly', 'Script encode function(s) only.')
  .option('-x, --fileExt [value]', 'Extension for output files. [' + defv.fileExt + ']', defv.fileExt)
  .parse(process.argv);

// TODO: Error if the destination is a directory (ends in slash) and it doesn't exist.

run();

function run() {
  var data = getHashData();
  var tplFiles = getTemplates();
  var i, output, file;
  // TODO: Break this loop out into 2 separate functions, 
  // one for outputting to a directory and the other for a single file.
  // TODO: When outputting to directory, prefix each file with db.swig.
  for (i = 0; i < tplFiles.length; i++) {
    if (data.directoryName) {
      file = path.basename(tplFiles[i], '.swig');
      if (file === 'db')
        continue;
      data.fileName = path.join(data.directoryName, file + '.' + app.fileExt);
    }
    output = swig.renderFile(tplFiles[i], data);
    pipeWriteOrAppend(output, data, (i === 0) || data.directoryName);
  }
}
/**
 * Gets the working data from a hashids.js instance, based on app options.
 */
function getHashData() {
  var hashids = new Hashids(app.salt, app.minHashLength, app.alphabet);
  var data = {
    database: app.database,
    schema: app.schema,
    inputAlphabet: app.alphabet,
    salt: hashids.salt,
    alphabet: hashids.alphabet,
    seps: hashids.seps,
    guards: hashids.guards,
    minHashLength: hashids.minHashLength,
    pipe: app.args.length === 0,
    fileName: '',
    directoryName: ''
  };
  if (!data.pipe) {
    data.fileName = app.args[0];
    data.directoryName = getDirectoryName(data);
  }
  return data;
}
/**
 * Returns the directory name that should be applied to the given data.
 */
function getDirectoryName(data) {
  var len = data.fileName.length,
      last;
  if (len === 0)
    return '';
  last = data.fileName[len - 1];
  if (last === '/' || last === '\\')
    return data.fileName;
  return '';
}

/**
 * Get the templates that should be rendered based on app options.
 */
function getTemplates() {
  var tpls = app.encodeOnly ? [
    './templates/tsql/encode1.swig',
    './templates/tsql/encode2.swig'
  ] : [
    './templates/tsql/consistentShuffle.swig',
    './templates/tsql/hash.swig',
    './templates/tsql/encode1.swig',
    './templates/tsql/encode2.swig'
  ];
  if (app.database)
    tpls.unshift('./templates/tsql/db.swig');
  return tpls;
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