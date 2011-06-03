# requires
coffee = require 'coffee-script'
fs = require 'fs'
vm = require 'vm'

# public functions
exports.compileFile = (file, mappings) ->
    fs.readFile file, (err, data) ->
        try
            js = coffee.compile(data.toString().trim())
            sandbox =
                exports: {}
                require: require
            vm.runInNewContext js, sandbox
            css = exports.compileObject sandbox.exports.css, mappings
            newFile = file.replace /\.css\.coffee$/i, '.css'
            fs.writeFile newFile, css, () ->
                console.log 'Written ' + newFile
        catch err
            console.log 'Error compiling ' + file + ': ' + err.message

exports.compileObject = (cssObject, mappings) ->
    outputList = []

    compileCssList = (cssObject) ->
        for selector, declarations of cssObject
            declarationText = []
            nestedSelectors = {}

            iterateDeclarations = (d) ->
                for key, value of d
                    if typeof value is 'object'
                        nestedSelectors["#{selector} #{key}"] = value
                    else
                        if mappings[key]?
                            iterateDeclarations mappings[key](value)
                        else
                            cssProperty = key.replace /[A-Z]/g, (s) -> '-' + s.toLowerCase()
                            declarationText.push "  #{cssProperty}: #{value};"

            iterateDeclarations declarations
            outputList.push "#{selector} {\n#{declarationText.join('\n')}\n}"
            compileCssList nestedSelectors

    compileCssList cssObject
    outputList.join '\n'