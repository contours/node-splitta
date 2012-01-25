class Document

  constructor: (text) ->
    @head = null
    @tail = null
    words = []
    for word in line.split(" ")
      if @maybeSentenceBound word
        # fragment constructor should tokenize
        @pushFragment new Fragment(words.join(" "))
        words = []
    @pushFragment new Fragment(words.join(" "), true)

  pushFragment: (frag) ->
    if @tail
      tail.next = frag
    else
      @head = frag
    @tail = frag

  maybeSentenceBound: (word) ->
    return true if word.substr(-1) in ".?!"
    #return true if word.match /.*[.?!]["')\]]*$/
    return false

  getStatistics: ->


  toString: ->
    frag = @head
    return (while frag
      string = frag.toString()
      frag = frag.next
      string).join "/n"


class Fragment

  constructor: (@text, @endsSentence = false) ->

  toString: ->
    return @text + (if @endsSentence then " <EOS> " else "")


