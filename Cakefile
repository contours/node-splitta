fs = require "fs"
Mocha = require "mocha"
CoffeeScript = require "coffee-script"
require "should"
{spawn} = require "child_process"

printLine = (line) -> process.stdout.write line + '\n'

run = (cmd, args) ->
  proc = spawn cmd, args
  proc.stderr.on "data", (buffer) -> console.log buffer.toString()
  proc.on "exit", (status) ->
    process.exit(1) if status != 0

lint = (file) ->
  fs.readFile file, (err, data) ->
    return console.error err if err?
    cs = data.toString()
    js = CoffeeScript.compile cs
    printIt = (buffer) -> printLine file + ':\t' + buffer.toString().trim()
    conf = __dirname + '/jsl.conf'
    jsl = spawn 'jsl', ['-nologo', '-stdin', '-conf', conf]
    jsl.stdout.on 'data', printIt
    jsl.stderr.on 'data', printIt
    jsl.stdin.write js
    jsl.stdin.end()

sourcefiles = ->
  files = fs.readdirSync "src"
  return ("src/" + file for file in files when file.match /\.coffee$/ )

task "lint", "Lint CoffeeScript files", ->
  lint file for file in sourcefiles()

task "build", "Compile CoffeeScript files", ->
  run "coffee", ["-c", "-o", "lib"].concat sourcefiles()

task "test", "Run tests", ->
  mocha = new Mocha()
  files = fs.readdirSync "spec"
  mocha.addFile "spec/#{file}" for file in files when file.match /\.coffee$/
  mocha.run -> console.log "Done."

