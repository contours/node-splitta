Document = require("./../Document").Document

describe "Document", ->

  it "should break text into a list of fragments", ->
    doc = new Document("this is fun. don't you think?")
    doc.head.toString().should.equal "this is fun."
    doc.tail.toString().should.equal "don't you think? <EOS> "
    doc.head.next.should.equal doc.tail

  describe "#maybeSentenceBound()", ->

    it "should return false if no '.', '?' or '!'", ->
      doc = new Document
      (doc.maybeSentenceBound "foo").should.be.false

    it "should return true if ends with '.', '?' or '!'", ->
      doc = new Document
      (doc.maybeSentenceBound "foo.").should.be.true
      (doc.maybeSentenceBound "foo?").should.be.true
      (doc.maybeSentenceBound "foo!").should.be.true

    it "should ignore quotes, parens and brackets at the end", ->
      doc = new Document
      (doc.maybeSentenceBound "(foo.)").should.be.true
      (doc.maybeSentenceBound "[foo.]").should.be.true
      (doc.maybeSentenceBound "'foo?'").should.be.true
      (doc.maybeSentenceBound '"foo!"').should.be.true
      (doc.maybeSentenceBound '("foo!")').should.be.true

    it "should not ignore other chars at the end", ->
      doc = new Document
      (doc.maybeSentenceBound "foo?foo").should.be.false