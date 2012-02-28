Model = require("./../Model").Model
Document = require("./../Document").Document
should = require "should"

describe "Model", ->

  describe "#load()", ->

    it "should load valid model dir without errors", (done) ->
      m = new Model __dirname + "/../models/wsj+brown"
      m.load done

    it "should return err given invalid model dir", (done) ->
      m = new Model __dirname
      m.load (err) ->
        should.exist err
        done()

  describe "#loadGzippedJSON()", ->

    it "should handle loading dicts (objects)", (done) ->
      m = new Model __dirname
      m.loadGzippedJSON __dirname + "/data.json.gz", (err, o) ->
        throw err if err?
        o.should.eql {a:1,b:2,c:3}
        done()

    it "should return err if no such file", (done) ->
      m = new Model __dirname
      m.loadGzippedJSON __dirname + "/no-such-file", (err, o) ->
        should.exist err
        done()

  describe "#formatFeatures()", ->

    it "should put each fragment's features on a line", (done) ->
      m = new Model __dirname + "/../models/wsj+brown"
      m.load ->
        doc = new Document "This is fun. Don't you think?"
        doc.featurize m
        m.formatFeatures(doc).should.equal(
          """
          0 39252:1 88873:1 96075:1 101779:1 132918:1 136787:1 139746:1 140781:1
          0 18164:1

          """)
        done()

  describe "#classify()", ->

    it "should throw err if model file does not exist", ->
      m = new Model __dirname
      d = new Document "a doe, a deer."
      (() -> m.classify d).should.throw /^.*\/svm_model does not exist$/

    it "should throw err if model has no features", ->
      m = new Model __dirname + "/../models/wsj+brown"
      d = new Document "a doe, a deer."
      (() -> m.classify d).should.throw "model has no features"