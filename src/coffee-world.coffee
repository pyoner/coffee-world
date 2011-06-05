#!/usr/bin/env coffee

# requires
cp = require 'child_process'
coffeeCss = require 'coffee-css'
coffeekup = require 'coffeekup'
fs = require 'fs'
path = require 'path'
util = require 'util'

# globals
watchedFiles = {}

# functions
compile = (fileName, callback = ->) ->
    if /\.css\.coffee$/i.test(fileName)
        coffeeCss.compile fileName, (err, fileName, newFileName) ->
            if err
                logCompileError fileName, err
            else
                logFileWritten newFileName
            callback()

    else if /\.html\.coffee$/i.test(fileName)
        fs.readFile fileName, (err, data) ->
            newFileName = fileName.replace /\.html.coffee$/i, '.html'
            try
                fs.writeFile newFileName, coffeekup.render(data.toString(), {format: on}), (err) ->
                    logFileWritten newFileName
            catch err
                logCompileError fileName, err
            callback()

    else if /\.coffee$/i.test(fileName)
        cp.exec "coffee -c \"#{fileName}\"", (err, stdout, stderr) ->
            if err
                logCompileError fileName, err
            else
                newFileName = fileName.replace /\.coffee$/i, '.js'
                util.log 'Written ' + newFileName
            callback()

compileAll = (callback) ->
    doFind compile, callback

compileAllIfNeeded = (callback) ->
    doFind compileIfNeeded, callback

compileIfNeeded = (fileName) ->
    fs.stat fileName, (err, stats) ->
        oldModifiedTime = watchedFiles[fileName]
        newModifiedTime = new Date(stats.mtime)
        watchedFiles[fileName] = newModifiedTime
        compile fileName if newModifiedTime > oldModifiedTime

doFind = (compileFunction, callback) ->
    cp.exec "find . -iname \"*.coffee\"", (err, stdout, stderr) ->
        if err then throw err
        fileList = stdout.split('\n')
        compileFunction fileName for fileName in fileList when fileName != ''
        callback()

logCompileError = (fileName, err) ->
    util.log 'Error compiling ' + fileName + ': ' + err.message

logFileWritten = (newFileName) ->
    util.log 'Written ' + newFileName

poller = () ->
    compileAllIfNeeded ->
        setTimeout poller, 1000

# main
exports.compile = compile

exports.start = () ->
    watchPath = process.cwd()
    args = process.argv[2..]
    isCompileAll = false
    for arg in args
        if arg in ['-a', '--all']
            isCompileAll = true
        else
            if path.existsSync(arg)
                watchPath = arg
            else
                console.log "Path '#{arg}' doesn't exist."
                process.exit 1
    util.log 'Watching ' + watchPath + '...'
    process.chdir(path.resolve(watchPath))
    if isCompileAll
        compileAll ->
            poller()
    else
        poller()