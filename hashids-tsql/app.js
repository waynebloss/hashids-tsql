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

swig.setDefaults({ allowCR: true });

app
  .version(pkg.version)
  .usage('[options] [file or directory/ path]')
  .option('-d, --database [name]', 'Database name. [' + defv.database + ']', defv.database)
  .option('-m, --schema [name]', 'Database schema. [' + defv.schema + ']', defv.schema)
  .option('-a, --ascii', 'Generate ASCII/varchar compatible function(s).')
  .option('-b, --bigint', 'Generate BIGINT compatible function(s).')
  .option('-e, --encodeOnly', 'Generate encode function(s) only.')
  .option('-s, --salt [value]', 'Salt. [random]', defv.salt)
  .option('-n, --minHashLength [n]', 'Minimum hash length. [' + defv.minHashLength.toString() + ']', defv.minHashLength)
  .option('-l, --alphabet [value]', 'Alphabet. [a-z,A-Z,1-9,0]', defv.alphabet)
  .option('-x, --fileExt [value]', 'Extension for output files. [' + defv.fileExt + ']', defv.fileExt)
  .option('-t, --test', 'Generate test procedureds and tables.')
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
    file = path.basename(tpl.files[i], '.sql');
    if (file === 'db')
      continue;
    data.fileName = path.join(data.directoryName, file + '.' + app.fileExt);
    output = swig.renderFile(tpl.files[i], data);
    output = tpl.db(data) + 
      tpl.go + 
      output + 
      tpl.go;
    fs.writeFileSync(data.fileName, output);
  }
}

function renderToFile(data, tpl) {
  var i, output;
  for (i = 0; i < tpl.files.length; i++) {
    output = swig.renderFile(tpl.files[i], data);
    output += tpl.go;
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
    output += tpl.go;
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
    minHashLength: app.minHashLength,
    pipe: app.args.length === 0,
    fileName: '',
    directoryName: '',
    testResults: ''
  };
  if (!data.pipe) {
    data.fileName = app.args[0];
    data.directoryName = getDirectoryName(data);
  }
  if (app.test)
    data.testResults = makeTestResults(hashids);
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
  var depFiles = [
    './templates/tsql/schema.sql',
    './templates/tsql/User Defined Types/ListOfBigint.sql',
    './templates/tsql/User Defined Types/ListOfInt.sql',
    './templates/tsql/Functions/consistentShuffle$.sql',
    './templates/tsql/Functions/hash$.sql'
  ],
  encodeFiles = [
    './templates/tsql/Functions/encode1*$.sql',
    './templates/tsql/Functions/encode2*$.sql',
    './templates/tsql/Functions/encodeList*$.sql',
    './templates/tsql/Functions/encodeSplit$.sql'
  ],
  testFiles = [
    './templates/tsql/Tables/ComputedTest.sql',
    './templates/tsql/Tables/Number.sql',
    './templates/tsql/Stored Procedures/getComputedTestDuplicateCounts.sql',
    './templates/tsql/Stored Procedures/listComputedTestDuplicates.sql',
    './templates/tsql/Stored Procedures/seedComputedTestTable.sql',
    './templates/tsql/Stored Procedures/seedNumberTable.sql',
    './templates/tsql/Stored Procedures/testComputedHashDuplicates.sql',
    './templates/tsql/test.sql'
  ],
  files = [path.join(__dirname, './templates/tsql/db.sql')],
  replaceDollar = (app.ascii ? 'A' : ''),
  replaceAsterisk = (app.bigint ? 'B' : ''),
  i, file;

  if (!app.encodeOnly) {
    for (i = 0; i < depFiles.length; i++) {
      file = depFiles[i]
        .replace('$', replaceDollar)
        .replace('*', replaceAsterisk);
      file = path.join(__dirname, file);
      files.push(file);
    }
  }

  for (i = 0; i < encodeFiles.length; i++) {
    file = encodeFiles[i]
      .replace('$', replaceDollar)
      .replace('*', replaceAsterisk);
    file = path.join(__dirname, file);
    files.push(file);
  }
  
  if (app.test) {
    for (i = 0; i < testFiles.length; i++) {
      file = path.join(__dirname, testFiles[i]);
      files.push(file);
    }
  }

  return {
    files: files,
    db: swig.compileFile(path.join(__dirname, './templates/tsql/db.sql')),
    go: swig.renderFile(path.join(__dirname, './templates/tsql/go.sql'))
  };
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

function makeTestResults(hashids) {
  // TODO: Change to os.EOL when swig does the same.
  // See https://github.com/paularmstrong/swig/issues/540
  var i, hash, nums, results = '';
  for (i = 1; i < 101; i++) {
    hash = hashids.encode(i);
    results += i.toString() + '   ' + hash + '\n';
  }
  results += '\n';
  for (i = 1; i < 101; i++) {
    hash = hashids.encode(1, i);
    results += '[1, ' + i.toString() + ']   ' + hash + '\n';
  }
  return results;
}