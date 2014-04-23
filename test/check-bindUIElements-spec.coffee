describe "Check MixinBackbone bindUIElements",->
  beforeEach ->
    View = Backbone.View.extend
      delegateEvents:(event)->
        @_checkEvents = event
        Backbone.View::delegateEvents.apply this, arguments

    TestView = MixinBackbone(View).extend
      ui:
        hello:".hello_class"
        bye:".bye_class"
      events:
        "click @ui.hello":->
        "click @ui.bye":->
        "click @ui.bye, @ui.hello":->
        "click .test":->
    @view = new TestView

  afterEach ->
    @view.remove()

  it "check ui",->
    expect(!!@view.ui).toBeTruthy()
    expect(2).toEqual _.size(_.keys(@view.ui))
    expect(!!@view.ui.hello).toBeTruthy()
    expect(!!@view.ui.bye).toBeTruthy()

  it "check length",->
    expect(2).toEqual _.size(@view.ui)
    expect(4).toEqual _.size(@view.events)
    expect(4).toEqual _.size(@view._checkEvents)

  it "check content click @ui.hello",->
    expect(_.keys(@view._checkEvents)).toContain "click .hello_class"

  it "check content click @ui.bye",->
    expect(_.keys(@view._checkEvents)).toContain "click .bye_class"

  it "check content click @ui.bye, @ui.hello",->
    expect(_.keys(@view._checkEvents)).toContain "click .bye_class, .hello_class"
