{Model} = require "../src/Model"
{Document} = require "../src/Document"
should = require "should"
async = require "async"

describe "Model", ->

  m = null
  afterEach (done) ->
    m.close done

  describe "#load()", ->

    it "should load valid model dir without errors", (done) ->
      m = new Model __dirname + "/../models/wsj+brown"
      m.load done

    it "should return err given invalid model dir", (done) ->
      m = new Model __dirname
      m.load (err) ->
        should.exist err
        done()

  describe "#loadGzippedJSON()", ->

    it "should handle loading dicts (objects)", (done) ->
      m = new Model __dirname
      m.loadGzippedJSON __dirname + "/data.json.gz", (err, o) ->
        return done err if err?
        o.should.eql {a:1,b:2,c:3}
        done()

    it "should return err if no such file", (done) ->
      m = new Model __dirname
      m.loadGzippedJSON __dirname + "/no-such-file", (err, o) ->
        should.exist err
        done()

  describe "#logistic()", ->

    it "should produce standard logistic sigmoid function", ->
      m = new Model __dirname
      m.logistic(-6).should.equal 0.002472623156634775
      m.logistic(-3).should.equal 0.04742587317756679
      m.logistic(0).should.equal 0.5
      m.logistic(3).should.equal 0.9525741268224331
      m.logistic(6).should.equal 0.9975273768433653

  describe "#classify()", ->

    it "should return err if model has not been loaded", (done) ->
      m = new Model __dirname
      d = new Document "a doe, a deer."
      m.classify d, (err) ->
        should.exist err
        done()

    it "should set prediction on fragments", (done) ->
      m = new Model __dirname + "/../models/wsj+brown"
      m.load (err) ->
        return done err if err?
        d = new Document "This is fun. Don't you think?"
        d.featurize m
        m.classify d, (err) ->
          return done err if err?
          (f.prediction for f in d.getFragments()).should.eql [ 0.8249208666161433, 0.6632801631840616 ]
          done()

  describe "#segment()", ->

    it "should return err if model file does not exist", (done) ->
      m = new Model __dirname
      m.segment "a doe, a deer.", (err) ->
        should.exist err
        done()

    it "should properly segment text into sentences", (done) ->
      m = new Model __dirname + "/../models/wsj+brown"
      m.load (err) ->
        return done err if err?
        m.segment "This is fun. Don't you think?", (err, segments) ->
          return done err if err?
          segments.should.eql ["This is fun.", "Don't you think?"]
          done()

    it "should properly segment long text into sentences", (done) ->
      m = new Model __dirname + "/../models/wsj+brown"
      m.load (err) ->
        return done err if err?
        m.segment "The philosophy of process is a venture in metaphysics, the general theory of reality. Its concern is with what exists in the world and with the terms of reference in which this reality is to be understood and explained. The task of metaphysics is, after all, to provide a cogent and plausible account of the nature of reality at the broadest, most synoptic and comprehensive level. And it is to this mission of enabling us to characterize, describe, clarify and explain the most general features of the real that process philosophy addresses itself in its own characteristic way. The guiding idea of its approach is that natural existence consists in and is best understood in terms of processes rather than things — of modes of change rather than fixed stabilities. For processists, change of every sort — physical, organic, psychological — is the pervasive and predominant feature of the real. Process philosophy diametrically opposes the view — as old as Parmenides and Zeno and the Atomists of Pre-Socratic Greece — that denies processes or downgrades them in the order of being or of understanding by subordinating them to substantial things. By contrast, process philosophy pivots on the thesis that the processual nature of existence is a fundamental fact with which any adequate metaphysic must come to terms. Process philosophy puts processes at the forefront of philosophical and specifically of ontological concern. Process should here be construed in pretty much the usual way — as a sequentially structured sequence of successive stages or phases. Three factors accordingly come to the fore: That a process is a complex — a unity of distinct stages or phases. A process is always a matter of now this, now that.  That this complex has a certain temporal coherence and unity, and that processes accordingly have an ineliminably temporal dimension.  That a process has a structure, a formal generic format in virtue of which every concrete process is equipped with a shape or format.  From the time of Aristotle, Western metaphysics has had a marked bias in favor of things or substances. However, another variant line of thought was also current from the earliest times onward. After all, the concentration on perduring physical things as existents in nature slights the equally good claims of another ontological category, namely processes, events, occurrences — items better indicated by verbs than nouns. And, clearly, storms and heat-waves are every bit as real as dogs and oranges.  What is characteristically definitive of process philosophizing as a distinctive sector of philosophical tradition is not simply the commonplace recognition of natural process as the active initiator of what exists in nature, but an insistence on seeing process as constituting an essential aspect of everything that exists — a commitment to the fundamentally processual nature of the real. For the process philosopher is, effectively by definition, one who holds that what exists in nature is not just originated and sustained by processes but is in fact ongoingly and inexorably characterized by them. On such a view, process is both pervasive in nature and fundamental for its understanding.  Like so much else in the field, process philosophy began with the ancient Greeks. The Greek theoretician Heraclitus of Ephesus (b. ca. 540 B.C.) — known even in antiquity as “the obscure” — is universally recognized as the founder of the process approach. His book “On Nature” depicted the world as a manifold of opposed forces joined in mutual rivalry, interlocked in constant strife and conflict. Fire, the most changeable and ephemeral of these elemental forces, is the basis of all: “This world-order … is … an ever living fire, kindling in measures and going out in measures” (Fr. 217, Kirk-Raven-Schofield). The fundamental “stuff” of the world is not a material substance of some sort but a natural process, namely “fire,” and all things are products of its workings (puros tropai). The variation of different states and conditions of fire — that most process-manifesting of the four traditional Greek elements — engenders all natural change. For fire is the destroyer and transformer of things and “All things happen by strife and necessity” (Fr. 211, ibid). And this changeability so pervades the world that “one cannot step twice into the same river” (Fr. 215, ibid). As Heraclitus saw it, reality is at bottom not a constellation of things at all, but one of processes: we must at all costs avoid the fallacy of substantializing nature into perduring things (substances) because it is not stable things but fundamental forces and the varied and fluctuating activities which they produce that make up this world of ours. Process is fundamental: the river is not an object, but an ever-changing flow; the sun is not a thing, but a flaming fire. Everything in nature is a matter of process, of activity, of change. Heraclitus taught that panta rhei (“everything flows”) and this principle exerted a profound influence on classical antiquity. Even Plato, who did not much like the principle (“like leaky pots” he added at Cratylus 440 C), came to locate his exception to it — the enduring and changeless “ideas” — in a realm wholly removed from the domain of material reality.  Heraclitus may accordingly be seen as the founding father of process philosophy, at any rate in the intellectual tradition of the West. And the static system of Parmenides affords its sharpest contrast and most radical opposition. However, the paradigm substance philosophy of classical antiquity was the atomism of Leucippus and Democritus and Epicurus, which pictured all of nature as composed of unchanging and inert material atoms whose only commerce with process was an alteration of their positioning in space and time. Here the properties of substances are never touched by change, which effects only their relations. It was this sort of view that Heraclitus preeminently sought to oppose.  In recent years, “process philosophy” has virtually become a code-word for the doctrines of Alfred North Whitehead and his followers. But of course, this cannot really be what process philosophy actually is. If there indeed is a “philosophy” of process, it must pivot not a thinker but on a theory. What is at issue must, in the end, be a philosophical position that has a larger life of its own, apart from any particular exposition or expositor. And in fact process philosophy is a well-defined and influential tendency of thought that can be traced back through the history of philosophy to the days of the Pre-Socratics. Its leading exponents were Heraclitus, Leibniz, Bergson, Peirce, and William James — and it ultimately moved on to include Whitehead and his school (Charles Hartshorne, Paul Weiss), but also other 20th Century philosophers such as Samuel Alexander, C. Lloyd Morgan, and Andrew Paul Ushenko.  Against this historical background, “process philosophy” may be understood as a doctrine invoking certain basic propositions: (1) That time and change are among the principal categories of metaphysical understanding, (2) That process is a principal category of ontological description, (3) That process is more fundamental, or at any rate not less fundamental than things for the purposes of ontological theory, (4) That several if not all of the major elements of the ontological repertoire (God, nature-as-a whole, persons, material substances) are best understood in process linked terms, and (5) That contingency, emergence, novelty, and creativity are among the fundamental categories of metaphysical understanding. A process philosopher, accordingly, is someone for whom temporality, activity, and change — of alteration, striving, passage, and novelty-emergence — are the cardinal factors for our understanding of the real.  The demise of classical atomism brought on by the dematerialization of physical matter through the rise of the quantum theory brings much aid and comfort to a process-oriented metaphysics. Matter in the small, as contemporary physics conceives it, is not a Rutherfordian planetary system of particle-like objects, but a collection of fluctuating processes organized into stable structures (insofar as there is indeed stability at all) by statistical regularities — i.e., by regularities of comportment at the level of aggregate phenomena. Twentieth century physics has thus turned the tables on classical atomism. Instead of very small things (atoms) combining to produce standard processes (windstorms and such) modern physics envisions very small processes (quantum phenomena) combining to produce standard things (ordinary macro-objects) as a result of their modus operandi.  For the process philosopher, the classical principle operari sequitur esse (functioning follows upon being) is reversed: his motto is the reverse esse sequitur operari. As he sees it, all is in the final analysis the product of processes. Process thus has priority over product — both ontologically and epistemically. As process philosophers see it, processes are basic and things derivative, because it takes a mental process (of separation) to extract “things” from the blooming buzzing confusion of the world’s physical processes. For process philosophy, what a thing is consists in what it does.  And insofar as reality itself is a vast macroprocess embracing a diversified manifold of microprocesses novelty, innovation, and the emergence of new focus is an inherent feature of the cosmic scene.  Evolution is an emblematic and paradigmatic process for process philosophy. For not only is evolution a process that makes philosophers and philosophy possible, but it provides a clear model for how processual novelty and innovation comes into operation in nature’s self-engendering and self-perpetuating scheme of things. Evolution, be it of organism or of mind, of subatomic matter or of the cosmos as a whole, reflects the pervasive role of process which philosophers of this school see as central both to the nature of our world and to the terms in which it must be understood. Change pervades nature. The passage of time leaves neither individuals nor types (species) of things statically invariant. Process at once destabilizes the world and is the cutting-edge of advance to novelty. And evolution of every level, physical, biological, and cosmic carries the burden of the work here. But does it work blindly?  On the issue of purposiveness in nature, process philosophers divide into two principal camps. On the one side is the naturalistic (and generally secularist) wing that sees nature’s processuality as a matter of an inner push or nisus to something new and different. On the other side is the teleological (and often theological) wing that sees nature’s processuality as a matter of teleological directedness towards a positive destination. Both agree in according a central role to novelty and innovation in nature. But the one (naturalistic) wing sees this in terms of chance-driven randomness that leads away from the settled formulations of an established past, while the other (teleological) wing sees this in terms of a goal-directed purposiveness preestablished by some value-geared directive force.  Process philosophy correspondingly has a complex, two sided relationship with the theory of evolution. For secular, atheological processists evolution typifies the creative workings of a self-sustaining nature that dispenses with the services of God. For theological processists like Teilhard de Chardin, evolution exhibits God’s handwriting in the book of nature. But processists of all descriptions see evolution not only as a crucial instrument for understanding the role of intelligence in the world’s scheme of things but also as a key aspect of the world’s natural development. And, more generally, the evolutionary process has provided process philosophy with one of its main models for how large scale collective processes (on the order of organic development at large) can inhere in and result from the operation of numerous small-scale individual processes (on the order of individual lives), thus accounting for innovation and creativity also on a macro-level scale. At every level of reality, “the many become one, and are increased by one”, as Whitehead puts it in Process and Reality (p. 20).  But there is one further complexity here. Where human intelligence is concerned, biological evolution is undoubtedly Darwinian, with teleologically blind natural selection operating with respect to teleologically blind random mutations. Cultural evolution, on the other hand, is generally Teilhardian, governed by a rationally-guided selection among purposefully devised mutational variations. Taken in all, cognitive evolution involves both components, superimposing rational selection on biological selection. Our cognitive capacities and faculties are part of the natural endowment we owe to biological evolution. But our cognitive methods, procedures, standards, and techniques are socio-culturally developed resources that evolve through rational selection in the process of cultural transmission through successive generations. Our cognitive hardware (mechanisms and capacities) develops through Darwinian natural selection, but our cognitive software (the methods and procedures by which we transact our cognitive business) develops in a Teilhardian process of rational selection that involves purposeful intelligence-guided variation and selection. Biology produces the instrument, so to speak, and culture writes the music — where obviously the former powerfully constrains the latter. (You cannot play the drums on a piano.)  The ancient Greeks grappled with the question: Is anything changeless, eternal, and exempt from the seemingly all-destructive ravages of time. Rejecting the idea of eternal material atoms, Plato opted for eternal changeless universals (“form,” “ideas”) and the Stoics for eternal, changeless laws. But the world-picture of modern science has seemingly blocked these solutions. For, as it sees the matter, species (natural kinds) are also children of time, not changelessly present but ever-changingly emergent under the aegis of evolutionary principles. The course of cosmic evolution brings nature’s laws also within the orbit of process, endowing these laws with a developmental dimension, (where, after all, was genetics in the microsecond after the big bang?). For process philosophy, nothing is eternal and secure from the changes wrought by time and its iron law that everything that comes into being must perish, so that mortality is omnipresent and death’s cold hand is upon all of nature — laws as well as things.  However, process philosophy does not see this gloomy truth as the end of the story. For process philosophy has always looked to evolutionary theory to pull the plum of collective progress from the pie of distributive mortality. In the small — item by item — nature’s processes are self-canceling: what arises in the course of time perishes in the course of time. But nevertheless the overall course of processual change tends to the development of an ever richer, more complex and sophisticated condition of things on the world’s ample stage. For there are processes and processes: processes of growth and decay, of expanding and contracting, of living and dying. Recognizing that this is so, process philosophy has always accentuated the positive and worn a decidedly optimistic mien. For it regards nature’s microprocesses as components of an overall macroprocess whose course is upwards rather than downwards, so to speak. Hitching its wagon to the star of a creative evolutionism, process philosophy sees nature as encompassing creative innovation, productive dynamism and an emergent development of richer, more complex and sophisticated forms of natural existence.  To be sure, there are, in theory, both productive and destructive processes, degeneration and decay being no less prominent in nature than growth and development. Historically, however, most process philosophers have taken a decidedly optimistic line and have envisioned a close relationship between process and progress. For them, this relationship is indicated by the macro-process we characterize as evolution. At every level of world history — the cosmic, the biological, the social, the intellectual — process philosophers have envisioned a developmental dynamic in which later is better — somehow superior in being more differentiated and sophisticated. Under the influence of Darwinian evolutionism, most process philosophers have envisioned a course of temporal development within which value is somehow survival-facilitative so that the arrangements which do succeed in establishing and perpetuating themselves will as a general tendency manage to have done so because they represent actual improvements in one way of another. (A decidedly optimistic tenor has prevailed throughout process philosophy.)  After all, differentiation is sophistication; detail is enrichment. The person who merely sees a bird does not see as much as the person who sees a finch, and she in turn does not see as much as the person who sees a Darwin finch. The realization and enhancement of detail bestows not just complexification as such but also sophistication. As process philosophy sees it, the world’s processuality involves not only change but improvement — the evolutionary realization — at large and on the whole — of what is not only different but also in some way better. Accordingly, novelty and fruitfulness compensate for transiency and mortality in process philosophy’s scheme of things.", (err, segments) ->
          return done err if err?
          segments.length.should.equal 110
          done()

    it "should properly segment parallel texts", (done) ->
      m = new Model __dirname + "/../models/wsj+brown"
      m.load (err) ->
        return done err if err?
        async.parallel {
          a: (callback) ->
            m.segment "This is fun. Don't you think?", callback
          b: (callback) ->
            m.segment "Sure it is. A lot of fun.", callback
          c: (callback) ->
            m.segment "Ok, I've had enough. Let's go home now.", callback
        }, (err, o) =>
          return done err if err?
          o.a.should.eql ["This is fun.", "Don't you think?"]
          o.b.should.eql ["Sure it is.", "A lot of fun."]
          o.c.should.eql ["Ok, I've had enough.", "Let's go home now."]
          done()


