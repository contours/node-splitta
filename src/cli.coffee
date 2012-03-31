splitta = require "./splitta"

run = ->

  fail = (err) ->
    console.error err
    process.exit 1

  text = ""
  process.stdin.on "data", (chunk) ->
    text += chunk

  process.stdin.on "error", (err) ->
    fail err

  process.stdin.on "end", ->
    splitta.segment text, (err, sentences) ->
      fail err if err?
      console.log sentence for sentence in sentences
      process.exit 0

  process.stdin.setEncoding "utf8"
  process.stdin.resume()

exports.run = run