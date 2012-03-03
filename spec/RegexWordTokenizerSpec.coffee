{tokenize} = require "../src/RegexWordTokenizer"

describe "RegexWordTokenizer", ->

  it "should normalize double quotes", ->
    (tokenize "''yo''").should.equal('" yo "')
    (tokenize "``yo``").should.equal('" yo "')
    (tokenize "“yo”").should.equal('" yo "')
    (tokenize "‘‘yo’’").should.equal('" yo "')

  it "should normalize single quotes", ->
    (tokenize "`don`t`").should.equal("' do n\'t '")
    (tokenize "‘don‘t’").should.equal("' do n\'t '")
    (tokenize "‘don’t’").should.equal("' do n\'t '")

  it "should separate punctuation (except period) from words", ->
    (tokenize "'whoa'").should.equal("' whoa '")
    (tokenize " 'whoa'").should.equal(" ' whoa '")
    (tokenize "who's").should.equal("who 's")
    (tokenize '"whoa"').should.equal('" whoa "')
    (tokenize "(whoa)").should.equal("( whoa )")
    (tokenize "{whoa}").should.equal("{ whoa }")
    (tokenize "[whoa]").should.equal("[ whoa ]")
    (tokenize "(whoa)hey").should.equal("( whoa ) hey")
    (tokenize "{whoa}hey").should.equal("{ whoa } hey")
    (tokenize "[whoa]hey").should.equal("[ whoa ] hey")
    (tokenize "hey(whoa)").should.equal("hey ( whoa )")
    (tokenize "hey{whoa}").should.equal("hey { whoa }")
    (tokenize "hey[whoa]").should.equal("hey [ whoa ]")
    (tokenize "whoa:hey").should.equal("whoa : hey")
    (tokenize "whoa;hey").should.equal("whoa ; hey")
    (tokenize "here&now").should.equal("here & now")
    (tokenize "#9").should.equal("# 9")
    (tokenize "*69").should.equal("* 69")
    (tokenize "ryanshaw@unc.edu").should.equal("ryanshaw @ unc.edu")
    (tokenize "hey!").should.equal("hey !")
    (tokenize "why?").should.equal("why ?")
    (tokenize "-urp").should.equal("- urp")
    (tokenize "sl -urp").should.equal("sl - urp")
    (tokenize "chicken-head").should.equal("chicken-head")
    (tokenize "but --why?").should.equal("but -- why ?")
    (tokenize '"nice job."').should.equal('" nice job. "')
    (tokenize '"nice job!"').should.equal('" nice job ! "')
    (tokenize '"nice job?"').should.equal('" nice job ? "')

  it "should treat double-hyphen as one token", ->
    (tokenize "or--maybe").should.equal("or -- maybe")
    (tokenize "or---maybe").should.equal("or --- maybe")

  it "should only separate comma if space follows", ->
    (tokenize "herp ,derp").should.equal("herp , derp")
    (tokenize ",derp").should.equal(", derp")
    (tokenize "herp,derp").should.equal("herp,derp")
    (tokenize "herp, derp").should.equal("herp , derp")
    (tokenize "herp,").should.equal("herp ,")

  it "should combine dots separated by whitespace to be a single token", ->
    (tokenize "well. . .").should.equal("well ... ")

  it "should separate 'No.6'", ->
    (tokenize "No.6").should.equal("No. 6")

  it "should separate words from ellipses", ->
    (tokenize "..hmm").should.equal(" .. hmm")
    (tokenize " ..hmm").should.equal(" .. hmm")
    (tokenize "well..hmm").should.equal("well .. hmm")
    (tokenize "well.. hmm").should.equal("well .. hmm")

  it "should separate '99%'", ->
    (tokenize "99%").should.equal("99 %")

  it "should separate '$99'", ->
    (tokenize "$99").should.equal("$ 99")

  it "should fix (n 't) --> ( n't)", ->
    (tokenize "couldn't").should.equal("could n't")

  it "should handle treebank tokenizer special words", ->
    (tokenize "cannot").should.equal("can not")

