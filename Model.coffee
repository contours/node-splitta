zlib = require "zlib"
fs = require "fs"
async = require "async"
Counter = require("./Counter").Counter

class Model

  constructor: (@path) ->
    @features = {}
    @lower_words = new Counter
    @non_abbrs = new Counter

  load: (callback) ->
    async.parallel {
      features: (callback) =>
        @loadGzippedJSON (@path + "/features.json.gz"), callback
      lower_words: (callback) =>
        @loadGzippedJSON (@path + "/lower_words.json.gz"), callback
      non_abbrs: (callback) =>
        @loadGzippedJSON (@path + "/non_abbrs.json.gz"), callback
    }, (err, o) =>
      @features = o.features
      @lower_words = new Counter o.lower_words
      @non_abbrs = new Counter o.non_abbrs
      callback err

  loadGzippedJSON: (path, callback) ->
    try
      zlib.gunzip fs.readFileSync(path), (err, buffer) ->
        throw err if err?
        callback null, JSON.parse buffer
    catch err
      callback err

#     def prep(self, doc):
#         self.lower_words, self.non_abbrs = doc.get_stats(verbose=False)
#         self.lower_words = dict(self.lower_words)
#         self.non_abbrs = dict(self.non_abbrs)

#     def train(self, doc):
#         abstract

#     def classify(self, doc, verbose=False):
#         abstract

#     def save(self):
#         """
#         save model objects in self.path
#         """
#         sbd_util.save_pickle(self.feats, self.path + 'feats')
#         sbd_util.save_pickle(self.lower_words, self.path + 'lower_words')
#         sbd_util.save_pickle(self.non_abbrs, self.path + 'non_abbrs')

exports.Model = Model