{Document} = require "./Document"
{Model} = require "./Model"

exports.segment = (text, callback) ->
  m = new Model __dirname + "/../models/wsj+brown"
  m.load (err) ->
    callback err if err?
    d = new Document text
    d.featurize m
    m.classify d, (err) ->
      callback err, d.segment()

exports.Model = Model
exports.Document = Document