{Document} = require "../src/Document"
{Model} = require "../src/Model"
should = require "should"

describe "Document", ->

  m = null
  afterEach (done) ->
    return done() unless m?
    m.close done

  it "should break text into a list of fragments", ->
    doc = new Document "this is fun. don't you think?"
    doc.head.toString().should.equal "this is fun."
    doc.tail.toString().should.equal "don't you think? <EOS> "
    doc.head.next.should.equal doc.tail

  describe "#getFragments()", ->

    it "should return an array of fragments", ->
      doc = new Document "this is fun. don't you think?"
      frags = doc.getFragments()
      frags.length.should.equal 2
      frags[0].toString().should.equal "this is fun."
      frags[1].toString().should.equal "don't you think? <EOS> "

  describe "#maybeSentenceBound()", ->

    it "should return false if no '.'", ->
      doc = new Document
      (doc.maybeSentenceBound "foo").should.be.false

    it "should return true if ends with '.'", ->
      doc = new Document
      (doc.maybeSentenceBound "foo.").should.be.true

    it "should ignore quotes, parens and brackets at the end", ->
      doc = new Document
      (doc.maybeSentenceBound "(foo.)").should.be.true
      (doc.maybeSentenceBound "[foo.]").should.be.true
      (doc.maybeSentenceBound "'foo.'").should.be.true
      (doc.maybeSentenceBound "‘foo.’").should.be.true
      (doc.maybeSentenceBound '“foo.”').should.be.true
      (doc.maybeSentenceBound '("foo.")').should.be.true

    it "should not ignore other chars at the end", ->
      doc = new Document
      (doc.maybeSentenceBound "foo.foo").should.be.false

  describe "#segment()", ->

    it "should properly segment text into sentences", (done) ->
      m = new Model __dirname + "/../models/wsj+brown"
      m.load (err) ->
        done err if err?
        d = new Document "On Jan. 20, former Sen. Barack Obama became the 44th President of the U.S. Millions attended the Inauguration."
        d.featurize m
        m.classify d, (err) ->
          done err if err?
          d.segment().should.eql [
            "On Jan. 20, former Sen. Barack Obama became the 44th President of the U.S.",
            "Millions attended the Inauguration." ]
          done()

    it "should throw error if document has not been featurized", ->
      d = new Document "yo"
      (->
        d.segment()).should.throw "document has not been featurized"

    it "should throw error if document has not been classified", ->
      m = new Model __dirname + "/../models/wsj+brown"
      m.load (err) ->
        done err if err?
        d = new Document "yo"
        d.featurize m
        (->
          d.segment()).should.throw "document has not been classified"

  describe "#toString()", ->

    it "should return empty string for empty doc", ->
      doc = new Document
      doc.toString().should.equal ""

    it "should put each fragment on a line", ->
      doc = new Document "this is fun. don't you think?"
      doc.toString().should.equal(
        """
        this is fun.
        don't you think? <EOS> """)