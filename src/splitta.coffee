{Document} = require "./Document"
{Model} = require "./Model"

exports.segment = (text, callback) ->
  m = new Model __dirname + "/../models/wsj+brown"
  m.load (err) ->
    return callback err if err?
    m.segment text, (err, sentences) ->
      return callback err if err?
      m.close ->
        callback null, sentences

exports.loadModel = (callback) ->
  m = new Model __dirname + "/../models/wsj+brown"
  m.load (err) -> callback err, m

exports.Model = Model
exports.Document = Document