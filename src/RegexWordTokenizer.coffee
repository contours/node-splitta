patterns = [
  # Patterns are from Dan Gillick's interpretation
  # of the Punkt Word Tokenizer: http://goo.gl/7BN1O

  # uniform double quotes
  [ /''/g, '"' ],
  [ /``/g, '"' ],
  [ /\u2018\u2018/g, '"' ],
  [ /\u2019\u2019/g, '"' ],
  [ /\u201C/g, '"' ],
  [ /\u201D/g, '"' ],

  # uniform single quotes
  [ /`/g, "'" ],
  [ /\u2018/g, "'" ],
  [ /\u2019/g, "'" ],

  # separate punctuation (except period) from words.
  [ /(^|\s)(')/g, "$1$2 " ],
  [ /(["\({\[:;&\*@#])(.)/g, "$1 $2" ],
  [ /(.)(?=[?!"\)}\]:;&\*@'])/g, "$1 " ],
  [ /([\)}\]])(.)/g, "$1 $2" ],
  [ /(.)(?=[({\[])/g, "$1 " ],
  [ /((^|\s)-)(?=[^-])/g, "$1 " ],

  # treat double-hyphen as one token
  [ /([^-])(--+)([^-])/g, "$1 $2 $3" ],

  # only separate comma if space follows
  [ /(\s|^)(,)(?=(\S))/g, "$1$2 " ],
  [ /(.)(,)(\s|$)/g, "$1 $2$3" ],

  # combine dots separated by whitespace to be a single token
  [ /\.\s\.\s\./g, "..." ],

  # separate "No.6"
  [ /([A-Za-z]\.)(\d+)/g, "$1 $2" ],

  # separate words from ellipses
  [ /([^\.]|^)(\.{2,})(.?)/g, "$1 $2 $3" ],
  [ /(^|\s)(\.{2,})([^\.\s])/g, "$1$2 $3" ],
  [ /([^\.\s])(\.{2,})($|\s)/g, "$1 $2$3" ],

  # separate "99%"
  [ /(\d)%/g, "$1 %" ],

  # separate "$99"
  [ /\$(\.?\d)/g, "$ $1" ],

  # # fix (n 't) --> ( n't)
  [ /([nN]) \'([tT])( |$)/g, " $1'$2$3" ],

  # treebank tokenizer special words
  [ /([Cc])annot/g, "$1an not" ],

  # normalize whitespace
  [ /\s+/g, " " ]
]

tokenize = (text) ->
  patterns.reduce ((text, [regex, replacement]) ->
    text.replace regex, replacement), text

exports.tokenize = tokenize