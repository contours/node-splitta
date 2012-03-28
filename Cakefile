fs = require "fs"
{exec} = require "child_process"
mocha = new (require "mocha")
require "should"

run = (cmd) ->
  exec cmd, (err, stdout, stderr) ->
    return console.error err if err?
    console.log stdout if stdout.length > 0
    console.error stderr if stderr.length > 0

compileFile = (src, dst) ->
  run "coffee -o #{dst} -c #{src}"

compileDir = (src, dst) ->
  fs.readdir "#{src}", (err, files) ->
    return console.log err if err?
    files.forEach (f) ->
      fs.stat "#{src}/#{f}", (err, stats) ->
        return console.log err if err?
        if stats.isFile() and f.match /\.coffee$/
          compileFile "#{src}/#{f}", "#{dst}"
        else if stats.isDirectory()
          compileDir "#{src}/#{f}", "#{dst}/#{f}"

task "compile", "Compile CoffeeScript files", (options) ->
  compileDir "src", "lib"

task "test", "Run tests", ->
  fs.readdir "spec", (err, files) ->
    return console.log err if err?
    files.forEach (f) ->
      mocha.addFile("spec/#{f}") if f.split('.').slice(-1)[0] == 'coffee'
    mocha.run ->
      console.log "Done."

