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
        done err if err?
        o.should.eql {a:1,b:2,c:3}
        done()

    it "should return err if no such file", (done) ->
      m = new Model __dirname
      m.loadGzippedJSON __dirname + "/no-such-file", (err, o) ->
        should.exist err
        done()

  describe "#formatFeatures()", ->

    it "should put each fragment's sorted features on a line", (done) ->
      m = new Model __dirname + "/../models/wsj+brown"
      m.load (err) ->
        done err if err?
        d = new Document "This is fun. Don't you think?"
        d.featurize m
        m.formatFeatures(d).should.equal(
          """
          0 39252:1 88873:1 96075:1 101779:1 132918:1 136787:1 139746:1 140781:1
          0 18164:1

          """)
        done()

  describe "#logistic()", ->

    it "should produce standard logistic sigmoid function", ->
      m = new Model __dirname
      m.logistic(-6).should.equal 0.002472623156634775
      m.logistic(-3).should.equal 0.04742587317756679
      m.logistic(0).should.equal 0.5
      m.logistic(3).should.equal 0.9525741268224331
      m.logistic(6).should.equal 0.9975273768433653

  describe "#classify()", ->

    it "should throw err if model file does not exist", ->
      m = new Model __dirname
      d = new Document "a doe, a deer."
      (() -> m.classify d).should.throw /^.*\/svm_model does not exist$/

    it "should throw err if model has no features", ->
      m = new Model __dirname + "/../models/wsj+brown"
      d = new Document "a doe, a deer."
      (() -> m.classify d).should.throw "model has no features"

    it "should set prediction on fragments", (done) ->
      m = new Model __dirname + "/../models/wsj+brown"
      m.load ->
        d = new Document "This is fun. Don't you think?"
        d.featurize m
        m.classify d, (err) ->
          done err if err?
          (f.prediction for f in d.getFragments()).should.eql [ 0.8249208666161433, 0.6632801631840616 ]
          done()