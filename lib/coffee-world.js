(function() {
  var coffeeCss, coffeekup, compile, compileAll, compileAllIfNeeded, compileIfNeeded, cp, doFind, fs, logCompileError, logFileWritten, path, poller, util, watchedFiles;
  cp = require('child_process');
  coffeeCss = require('coffee-css');
  coffeekup = require('coffeekup');
  fs = require('fs');
  path = require('path');
  util = require('util');
  watchedFiles = {};
  compile = function(fileName, callback) {
    if (callback == null) {
      callback = function() {};
    }
    if (/\.css\.coffee$/i.test(fileName)) {
      return coffeeCss.compile(fileName, function(err, fileName, newFileName) {
        if (err) {
          logCompileError(fileName, err);
        } else {
          logFileWritten(newFileName);
        }
        return callback();
      });
    } else if (/\.html\.coffee$/i.test(fileName)) {
      return fs.readFile(fileName, function(err, data) {
        var newFileName;
        newFileName = fileName.replace(/\.html.coffee$/i, '.html');
        try {
          fs.writeFile(newFileName, coffeekup.render(data.toString(), {
            format: true
          }), function(err) {
            return logFileWritten(newFileName);
          });
        } catch (err) {
          logCompileError(fileName, err);
        }
        return callback();
      });
    } else if (/\.coffee$/i.test(fileName)) {
      return cp.exec("coffee -c \"" + fileName + "\"", function(err, stdout, stderr) {
        var newFileName;
        if (err) {
          logCompileError(fileName, err);
        } else {
          newFileName = fileName.replace(/\.coffee$/i, '.js');
          util.log('Written ' + newFileName);
        }
        return callback();
      });
    }
  };
  compileAll = function(callback) {
    return doFind(compile, callback);
  };
  compileAllIfNeeded = function(callback) {
    return doFind(compileIfNeeded, callback);
  };
  compileIfNeeded = function(fileName) {
    return fs.stat(fileName, function(err, stats) {
      var newModifiedTime, oldModifiedTime;
      oldModifiedTime = watchedFiles[fileName];
      newModifiedTime = new Date(stats.mtime);
      watchedFiles[fileName] = newModifiedTime;
      if (newModifiedTime > oldModifiedTime) {
        return compile(fileName);
      }
    });
  };
  doFind = function(compileFunction, callback) {
    return cp.exec("find . -iname \"*.coffee\"", function(err, stdout, stderr) {
      var fileList, fileName, _i, _len;
      if (err) {
        throw err;
      }
      fileList = stdout.split('\n');
      for (_i = 0, _len = fileList.length; _i < _len; _i++) {
        fileName = fileList[_i];
        if (fileName !== '') {
          compileFunction(fileName);
        }
      }
      return callback();
    });
  };
  logCompileError = function(fileName, err) {
    return util.log('Error compiling ' + fileName + ': ' + err.message);
  };
  logFileWritten = function(newFileName) {
    return util.log('Written ' + newFileName);
  };
  poller = function() {
    return compileAllIfNeeded(function() {
      return setTimeout(poller, 1000);
    });
  };
  exports.compile = compile;
  exports.start = function() {
    var arg, args, isCompileAll, watchPath, _i, _len;
    watchPath = process.cwd();
    args = process.argv.slice(2);
    isCompileAll = false;
    for (_i = 0, _len = args.length; _i < _len; _i++) {
      arg = args[_i];
      if (arg === '-a' || arg === '--all') {
        isCompileAll = true;
      } else {
        if (path.existsSync(arg)) {
          watchPath = arg;
        } else {
          console.log("Path '" + arg + "' doesn't exist.");
          process.exit(1);
        }
      }
    }
    util.log('Watching ' + watchPath + '...');
    process.chdir(path.resolve(watchPath));
    if (isCompileAll) {
      return compileAll(function() {
        return poller();
      });
    } else {
      return poller();
    }
  };
}).call(this);
