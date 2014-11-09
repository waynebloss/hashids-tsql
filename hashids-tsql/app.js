'use strict';

var pkg = require('./package.json');
var fs = require('fs');
var path = require('path');
var Hashids = require('hashids');
var swig = require('swig');
var mkdirp = require('mkdirp');

var app = require('commander');
var defv = {
  database: 'HashidsTsql',
  schema: 'hashids',
  salt: makeSalt(),
  minHashLength: 0,
  alphabet: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
  seps: 'cfhistuCFHISTU',
  fileExt: 'sql'
};

app
  .version(pkg.version)
  .usage('[options] [file path or directory/ path]')
  .option('-d, --database [name]', 'Database name.', defv.database)
  .option('-n, --schema [name]', 'Database schema [hashids].', defv.schema)
  .option('-s, --salt [value]', 'Salt. [random]', defv.salt)
  .option('-l, --minHashLength [n]', 'Minimum hash length. [' + defv.minHashLength.toString() + ']', defv.minHashLength)
  .option('-a, --alphabet [value]', 'Alphabet. [a-z,A-Z,1-9,0]', defv.alphabet)
  .option('-e, --encodeOnly', 'Script encode function(s) only.')
  .option('-x, --fileExt [value]', 'Extension for output files. [' + defv.fileExt + ']', defv.fileExt)
  .parse(process.argv);

run();

function run() {
  var data = getHashData();
  var tpl = getTemplates();
  
  if (data.directoryName)
    renderToDirectory(data, tpl);
  else if (data.fileName)
    renderToFile(data, tpl);
  else
    renderToStdout(data, tpl);
}

function renderToDirectory(data, tpl) {
  var i, output, file;
  mkdirp.sync(data.directoryName);
  for (i = 0; i < tpl.files.length; i++) {
    file = path.basename(tpl.files[i], '.swig');
    if (file === 'db')
      continue;
    data.fileName = path.join(data.directoryName, file + '.' + app.fileExt);
    output = swig.renderFile(tpl.files[i], data);
    output = tpl.db(data) + output;
    fs.writeFileSync(data.fileName, output);
  }
}

function renderToFile(data, tpl) {
  var i, output;
  for (i = 0; i < tpl.files.length; i++) {
    output = swig.renderFile(tpl.files[i], data);
    if (i === 0)
      fs.writeFileSync(data.fileName, output);
    else
      fs.appendFileSync(data.fileName, output);
  }
}

function renderToStdout(data, tpl) {
  var i, output;
  for (i = 0; i < tpl.files.length; i++) {
    output = swig.renderFile(tpl.files[i], data);
    console.log(output);  // CONSIDER: Is this the best way to pipe to stdout?
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
  var tpl = {
    files: app.encodeOnly ? [
      './templates/tsql/Functions/encode1.swig',
      './templates/tsql/Functions/encode2.swig',
      './templates/tsql/Functions/encodeList.swig',
      './templates/tsql/Functions/encodeSplit.swig'
    ] : [
      './templates/tsql/schema.swig',
      './templates/tsql/User Defined Types/ListOfBigint.swig',
      './templates/tsql/User Defined Types/ListOfInt.swig',
      './templates/tsql/Functions/consistentShuffle.swig',
      './templates/tsql/Functions/hash.swig',
      './templates/tsql/Functions/encode1.swig',
      './templates/tsql/Functions/encode2.swig',
      './templates/tsql/Functions/encodeList.swig',
      './templates/tsql/Functions/encodeSplit.swig'
    ]
  };
  tpl.files.unshift('./templates/tsql/db.swig');
  tpl.db = swig.compileFile('./templates/tsql/db.swig');
  return tpl;
}
/**
 * Creates a new random salt value.
 */
function makeSalt() {
  var hrtime = process.hrtime(),
      value = hrtime[0] + process.pid + hrtime[1] + parseInt(Math.random(), 10),
      salt = 'D38298C1a5354BFA859f1FD2E0Fd3774',
      hashids = new Hashids(salt, 12);
  
  salt = hashids.encode(value);
  
  return salt;
}