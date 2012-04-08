{Document} = require "./Document"
{Model} = require "./Model"

exports.segment = (text, callback) ->
  m = new Model __dirname + "/../models/wsj+brown"
  m.load (err) ->
    callback err if err?
    m.segment text, callback

exports.loadModel = (callback) ->
  m = new Model __dirname + "/../models/wsj+brown"
  m.load (err) -> callback err, m

exports.Model = Model
exports.Document = Document