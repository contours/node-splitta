async = require "async"
fs = require "fs"
path = require "path"
temp = require "temp"
zlib = require "zlib"
{exec} = require "child_process"
{Counter} = require "./Counter"
{Document} = require "./Document"

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
        callback err, JSON.parse buffer
    catch err
      callback err

  formatFeatures: (doc) ->
    lines = []
    for frag in doc.getFragments()
      features = (@features[f] for f in frag.getFeatures() when f of @features)
      features.sort (x,y) -> x-y
      lines.push("0 " + ("#{f}:1" for f in features).join " ")
    return lines.join("\n") + "\n"

  logistic: (x, y=1) ->
    return 1.0 / (1 + Math.pow Math.E, (-1 * y * x))

  classify: (doc, callback) ->
    model_file_path = @path + "/svm_model"
    if not path.existsSync(model_file_path)
      throw new Error "#{model_file_path} does not exist"
    if (f for own f of @features).length == 0
      throw new Error "model has no features"

    test_file = temp.openSync()
    fs.writeSync test_file.fd, @formatFeatures(doc), null
    fs.closeSync test_file.fd

    pred_file = temp.openSync()

    cmd = "svm_classify #{test_file.path} #{model_file_path} #{pred_file.path}"
    exec cmd, (err, stdout, stderr) =>
      callback err if err?
      lines =  (fs.readFileSync pred_file.path).toString().split("\n")
      predictions = lines.map parseFloat
      for frag, i in doc.getFragments()
        frag.prediction = @logistic(predictions[i])
      callback null

  segment: (text, callback) ->
      doc = new Document text
      doc.featurize this
      @classify doc, (err) ->
        callback err, doc.segment()

#     def prep(self, doc):
#         self.lower_words, self.non_abbrs = doc.get_stats(verbose=False)
#         self.lower_words = dict(self.lower_words)
#         self.non_abbrs = dict(self.non_abbrs)

#     def train(self, doc):
#         abstract

#     def save(self):
#         """
#         save model objects in self.path
#         """
#         sbd_util.save_pickle(self.feats, self.path + 'feats')
#         sbd_util.save_pickle(self.lower_words, self.path + 'lower_words')
#         sbd_util.save_pickle(self.non_abbrs, self.path + 'non_abbrs')

exports.Model = Model