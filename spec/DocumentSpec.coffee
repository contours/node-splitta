Document = require("./../Document").Document

describe "Document", ->

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