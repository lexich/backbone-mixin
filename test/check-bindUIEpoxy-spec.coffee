describe "Check MixinBackbone bindUIEpoxy",->
  beforeEach ->
    TestView = MixinBackbone(Backbone.View).extend
      ui:
        hello:".hello_class"
        bye:".bye_class"
      bindings:
        "@ui.hello":"text:hello"
        "@ui.bye":"text:hello"
        ".hello_n_class":"text:hello"
    @view = new TestView
  afterEach ->
    @view.remove()

  it "check bindings length",->
    expect(_.keys(@view.bindings).length).toEqual 3
  it "check css class selector",->
    expect(_.keys(@view.bindings)).toContain ".hello_n_class"
  it "check @ui.hello using",->
    expect(_.keys(@view.bindings)).toContain ".hello_class"
  it "check @ui.bye using",->
    expect(_.keys(@view.bindings)).toContain ".bye_class"
