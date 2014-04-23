describe "Check MixinBackbone template engine",->
  beforeEach ->
    $("body").html "<script id='Test' type='text/html'><h1>Hello <%= name %></h1></script>"

  afterEach ->
    $("#Test").remove()

  it "check template",->
    TestView = MixinBackbone(Backbone.View).extend
      template:"#Test"
    view = new TestView
    expect(view.$el.html()).toEqual "<h1>Hello &lt;%= name %&gt;</h1>"
    view.remove()

  it "check templateData & templateFunc & undercore template engine",->
    TestView = MixinBackbone(Backbone.View).extend
      template:"#Test"
      templateData:{name:"world"}
    view = new TestView
    expect(view.$el.html()).toEqual "<h1>Hello world</h1>"
    view.remove()