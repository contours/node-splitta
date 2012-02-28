Fragment = require("./../Document").Fragment
Model = require("./../Model").Model
Counter = require("./../Counter").Counter
tokenize = require("./../RegexWordTokenizer").tokenize

describe "Fragment", ->

  it "should tokenize text upon construction", ->
    frag = new Fragment ["don't", "you", "think?"]
    frag.tokenized_text.should.equal(tokenize "don't you think?")
    frag.tokens.should.eql((frag.clean frag.tokenized_text).split " ")

  describe "#clean()", ->

    it "should normalize numbers", ->
      frag = new Fragment
      (frag.clean "no. 1").should.equal "no. <NUM>"
      (frag.clean ".01").should.equal "<NUM>"
      (frag.clean "$9.99").should.equal "$<NUM>"
      (frag.clean "10,000").should.equal "<NUM>"

    it "should discard weird punctutation", ->
      frag = new Fragment
      (frag.clean "{hey}").should.equal "hey"
      (frag.clean "~rybesh").should.equal "rybesh"
      (frag.clean "we're #1").should.equal "we're <NUM>"
      (frag.clean "*69").should.equal "<NUM>"
      (frag.clean "google+").should.equal "google"
      (frag.clean "a|b").should.equal "ab"

    it "should discard series of dashes", ->
      frag = new Fragment
      (frag.clean "word--life").should.equal "word life"
      (frag.clean "word---life").should.equal "word life"
      (frag.clean "word----life").should.equal "word life"

  describe "#featurize()", ->

    it "should calculate features correctly", ->
      frag = new Fragment [ "history." ]
      frag.next = new Fragment [ "Around" ]
      model = new Model
      model.non_abbrs = new Counter { history: 66 }
      model.lower_words = new Counter { around: 222 }
      frag.featurize model
      # (1) w1: word that includes a possible sentence boundary
      frag.features.w1.should.equal "history."
      # (2) w2: the next word, if it exists
      frag.features.w2.should.equal "Around"
      # (3) w1length: number of alphabetic characters in w1
      frag.features.w1length.should.equal "7"
      # (4) w2cap: true if w2 is capitalized
      frag.features.w2cap.should.equal "True"
      # (5) both: w1 and w2
      frag.features.both.should.equal "history._Around"
      # (6) w1abbr: log count in training of w1 without a final period
      frag.features.w1abbr.should.equal "4"
      # (7) w2lower: log count in training of w2 as lowercased
      frag.features.w2lower.should.equal "5"
      # (8) w1w2upper: w1 and true if w2 is capitalized
      frag.features.w1w2upper.should.equal "history._True"

  describe "#getFeatures()", ->

    it "should return array of features", ->
      frag = new Fragment [ "history." ]
      frag.next = new Fragment [ "Around" ]
      model = new Model
      model.non_abbrs = new Counter { history: 66 }
      model.lower_words = new Counter { around: 222 }
      frag.featurize model
      frag.getFeatures().sort().should.eql [
        "both_history._Around",
        "w1_history.",
        "w1abbr_4",
        "w1length_7",
        "w1w2upper_history._True",
        "w2_Around",
        "w2cap_True",
        "w2lower_5" ]

    it "should return empty array if not yet featurized", ->
      frag = new Fragment
      frag.getFeatures().should.eql []



