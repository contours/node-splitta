Model = require("./../Model").Model
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