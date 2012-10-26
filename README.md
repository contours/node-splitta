node-splitta
------------

A Node.js port of [`splitta`](http://code.google.com/p/splitta/), Dan Gillick's statistical sentence boundary detector. It does not provide all the functionality of `splitta`. It requires a small [patch](https://github.com/rybesh/homebrew-alt/blob/master/svm_light.rb) of [`svmlight`](http://svmlight.joachims.org/) to run. This patch simply adds a binary called `svm_classifyd`, basically a classifier which can run as a daemon and be communicated with over stdin/stdout, to avoid having to spawn new `svm_classify` processes. See [`Model.coffee`](https://github.com/rybesh/node-splitta/blob/master/src/Model.coffee) for the details.

To install the patched `svmlight` using [Homebrew](http://mxcl.github.com/homebrew/): 

    $ brew tap rybesh/homebrew-alt
    $ brew install svmlight

To install `node-splitta`:

    $ git clone https://github.com/rybesh/node-splitta.git
    $ cd node-splitta
    $ npm install
    $ npm test 

