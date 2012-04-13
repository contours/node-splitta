async = require "async"
fs = require "fs"
path = require "path"
zlib = require "zlib"
{carry} = require "carrier"
{spawn} = require "child_process"
{Pool} = require "generic-pool"
{Counter} = require "./Counter"
{Document} = require "./Document"

class Model

  constructor: (@path) ->
    @features = {}
    @lower_words = new Counter
    @non_abbrs = new Counter
    @pool = null

  load: (callback) ->
    model_file_path = @path + "/svm_model"
    unless path.existsSync model_file_path
      return callback new Error "#{model_file_path} does not exist"
    async.parallel {
      features: (callback) =>
        @loadGzippedJSON (@path + "/features.json.gz"), callback
      lower_words: (callback) =>
        @loadGzippedJSON (@path + "/lower_words.json.gz"), callback
      non_abbrs: (callback) =>
        @loadGzippedJSON (@path + "/non_abbrs.json.gz"), callback
    }, (err, o) =>
      return callback err if err?
      if (f for own f of o.features).length == 0
        return callback new Error "model has no features"
      @features = o.features
      @lower_words = new Counter o.lower_words
      @non_abbrs = new Counter o.non_abbrs
      @pool = Pool {
        name: 'svmclassify'
        create: (callback) ->
          classifier = spawn "svm_classifyd", [model_file_path]
          classifier.carrier = carry classifier.stdout
          callback null, classifier
        destroy: (child) ->
          child.kill "SIGINT"
        max: 5
        idleTimeoutMillis: 5000
      }
      callback()

  close: (callback) ->
    return callback() unless @pool?
    @pool.drain => @pool.destroyAllNow -> callback()

  loadGzippedJSON: (path, callback) ->
    try
      zlib.gunzip fs.readFileSync(path), (err, buffer) ->
        return callback err if err?
        callback null, JSON.parse buffer
    catch err
      callback err

  logistic: (x, y=1) ->
    return 1.0 / (1 + Math.pow Math.E, (-1 * y * x))

  classify: (doc, callback) ->
    return callback new Error "model has not been loaded" unless @pool?
    @pool.acquire (err, classifier) =>
      if err?
        @close -> callback err
        return

      fragments = doc.getFragments()

      # callback with an err if classifier prints to stderr
      classifier.stderr.on "data", (data) ->
         @close -> callback new Error data.toString()

      # callback with an err if the classifier dies or is killed abnormally
      classifier.on "exit", (code, signal) ->
        unless signal == "SIGINT"
          @close ->
            if code?
              callback new Error "classifer exited with code #{code})"
            else if signal?
              callback new Error "classifer killed with #{signal}"

      # parse classifier output
      index = 0
      classifier.carrier.on "line", (line) =>
        value = parseFloat line
        if isNaN value
          @close -> callback new Error "unexpected output: #{line}"
          return
        if index == fragments.length
          if classifier?
            classifier.carrier.removeAllListeners()
            classifier.stderr.removeAllListeners()
            classifier.removeAllListeners()
            @pool.release classifier
            classifier = null
            callback null
        else
          fragments[index++].prediction = @logistic value

      # format fragment features and send to classifier
      for frag in fragments
        feats = (@features[f] for f in frag.getFeatures() when f of @features)
        feats.sort (x,y) -> x-y
        classifier.stdin.write(
          "0 " + ("#{f}:1" for f in feats).join(" ") + "\n")
      classifier.stdin.write "\n"

  segment: (text, callback) ->
      doc = new Document text
      doc.featurize this
      @classify doc, (err) ->
        return callback err if err?
        callback null, doc.segment()

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