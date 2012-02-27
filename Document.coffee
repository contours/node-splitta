tokenize = require("./RegexWordTokenizer").tokenize

class Document

  constructor: (text) ->
    return if not text?
    @head = null
    @tail = null
    words = []
    for word in text.split(" ")
      words.push word
      if @maybeSentenceBound word
        @pushFragment new Fragment(words)
        words = []
    if words.length > 0
      @pushFragment new Fragment(words)
    @tail.endsSentence = true

  pushFragment: (frag) ->
    if @tail
      @tail.next = frag
    else
      @head = frag
    @tail = frag

  maybeSentenceBound: (word) ->
    return true if ".?!".indexOf(word.substr -1) > 0
    return true if word.match /.*[\.\?!][\"\')\]]*$/
    return false

  getStatistics: ->
    null

  featurize: (model) ->
    frag = @head
    while frag
      frag.featurize()
      frag = frag.next

  toString: ->
    frag = @head
    return (while frag
      string = frag.toString()
      frag = frag.next
      string).join "/n"


class Fragment

  constructor: (words=[], @endsSentence = false) ->
    @text = words.join " "
    @next = null
    @features = null
    @tokenized_text = tokenize(@text)
    @tokens = (@clean @tokenized_text).split " "

  clean: (text) ->
    text = text.replace /[.,\d]*\d/g, "<NUM>"
    text = text.replace /[^a-zA-Z0-9,.;:<>\-\'\/\?!$% ]/g, ""
    text = text.replace /-{2,}/g, " "
    return text

  featurize: (model) ->
    # ... w1. (sentence boundary?) w2 ...
    # Features, listed roughly in order of importance:
    # (1) w1: word that includes a period
    # (2) w2: the next word, if it exists
    # (3) w1length: number of alphabetic characters in w1
    # (4) w2cap: true if w2 is capitalized
    # (5) both: w1 and w2
    # (6) w1abbr: log count in training of w1 without a final period
    # (7) w2lower: log count in training of w2 as lowercased
    # (8) w1w2upper: w1 and true if w2 is capitalized
    w1 = w2 = ""
    w1 = @tokens.slice(-1)[0] if @tokens.length > 0
    if @next?
      w2 = @next.tokens[0] if @next.tokens.length > 0

    c1 = w1.replace /^.+?-/, ""
    c2 = w2.replace /-.+?$/, ""

    features = {}
    addFeature = (name, value) ->
      features[name] = value.toString()

    addFeature "w1", c1
    addFeature "w2", c2
    addFeature "both", c1 + "_" + c2

    if c1.replace(".","","g").match /^[A-Za-z]+$/
      addFeature "w1length", Math.min(10, (c1.replace /\W/g, "").length)
      addFeature "w1abbr",
        parseInt Math.log(1 + model.non_abbrs.get(c1.slice 0,-1))
    if c2.replace(".","","g").match /^[A-Za-z]+$/
      addFeature "w2cap", (c2[0].match /[A-Z]/)?
      addFeature "w2lower",
        parseInt Math.log(1 + model.lower_words.get c2.toLowerCase())
      addFeature "w1w2upper", c1 + "_" + features["w2cap"]

    return features

  toString: ->
    return @text + (if @endsSentence then " <EOS> " else "")

exports.Document = Document
exports.Fragment = Fragment