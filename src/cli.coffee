{Document} = require "./Document"
{Model} = require "./Model"

run = ->

  fail = (err) ->
    console.error err
    process.exit 1

  segment = (text, callback) ->
    m = new Model __dirname + "/../models/wsj+brown"
    m.load (err) ->
      callback err if err?
      d = new Document text
      d.featurize m
      m.classify d, (err) ->
        callback err, d.segment()

  text = ""
  process.stdin.on "data", (chunk) ->
    text += chunk

  process.stdin.on "error", (err) ->
    fail err

  process.stdin.on "end", ->
    segment text, (err, sentences) ->
      fail err if err?
      console.log sentence for sentence in sentences
      process.exit 0

  process.stdin.setEncoding "utf8"
  process.stdin.resume()

exports.run = run