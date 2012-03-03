{Counter} = require("../src/Counter")

describe "Counter", ->

  it "should start at zero", ->
    c = new Counter
    (c.get "foo").should.equal 0

  it "should be initializable", ->
    c = new Counter { foo: 1 }
    (c.get "foo").should.equal 1

  it "should increment", ->
    c = new Counter
    c.count "bar"
    (c.get "bar").should.equal 1
    c.count "bar"
    (c.get "bar").should.equal 2

  it "should total up", ->
    c = new Counter
    c.totalCount().should.equal 0
    c.count "foo"
    c.count "foo"
    c.count "foo"
    c.count "bar"
    c.totalCount().should.equal 4

  it "should normalize counts", ->
    c = new Counter
    c = c.normalize() # shouldn"t throw error
    c.totalCount().should.equal 0
    c.count "foo"
    c.count "foo"
    c.count "foo"
    c.count "bar"
    c = c.normalize()
    (c.get "foo").should.equal 0.75
    (c.get "bar").should.equal 0.25
    c.totalCount().should.equal 1

