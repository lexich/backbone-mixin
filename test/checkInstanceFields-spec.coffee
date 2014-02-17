describe "Check MixinBackbone bindRegions", ->
  it "check regions",->
    TestView = MixinBackbone(Backbone.View).extend
      regions:
        test:".test"
    view = new TestView()
    expect(!!view.regions).toBeTruthy()
    view.remove()
    expect(!view.test).toBeTruthy()
  it "check custom regions with selector",->
    RegionView = do(SuperClass = MixinBackbone(Backbone.View) )->
      SuperClass.extend
        custom_region:true
        remove:->
          @remove_custom_view = true
          SuperClass::remove.apply this, arguments

    TestView = MixinBackbone(Backbone.View).extend
      regions:
        test: el:".test", view:RegionView

    view = new TestView
    expect(!!view.regions).toBeTruthy()
    expect(!!view.test).toBeTruthy()
    expect(!!view.test.custom_region).toBeTruthy()
    test = view.test
    view.remove()
    expect(!view.test).toBeTruthy()
    expect(!!test.remove_custom_view).toBeTruthy()


  it "check custom regions with dom element",->
    RegionView = MixinBackbone(Backbone.View).extend {}
    $el = $("<div class='test'/>")
    TestView = MixinBackbone(Backbone.View).extend
      regions:
        test: el:$el, view:RegionView
    view = new TestView()
    expect(view.test.$el).toEqual($el)
    view.remove()

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
    expect(!!@view.__bindUIElements).toBeTruthy()
    expect(_.size(_.keys(@view.ui))).toEqual(2)
    expect(!!@view.ui.hello).toBeTruthy()
    expect(!!@view.ui.bye).toBeTruthy()

  it "check length",->
    expect(_.size(@view.ui)).toEqual(2)
    expect(_.size(@view.events)).toEqual(4)
    expect(_.size(@view._checkEvents)).toEqual(4)

  it "check content click @ui.hello",->
    expect(_.keys(@view._checkEvents)).toContain "click .hello_class"

  it "check content click @ui.bye",->
    expect(_.keys(@view._checkEvents)).toContain "click .bye_class"

  it "check content click @ui.bye, @ui.hello",->
    expect(_.keys(@view._checkEvents)).toContain "click .bye_class, .hello_class"

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

describe "Check MixinBackbone DI",->
  beforeEach ->
    @TestView = MixinBackbone(Backbone.View).extend {}
    @TestViewDI = Backbone.View.extend {}
    @view = new @TestView

  afterEach ->
    @view.remove()

  it "check DI keys works",->
    view1 = @view.getViewDI @TestViewDI
    diKey = "#{@TestViewDI._$_di}"
    view2 = @view.getViewDI @TestViewDI
    expect(diKey).toEqual "#{@TestViewDI._$_di}"

  it "check DI clean memory",->
    view = new @TestView
    diView = view.getViewDI @TestViewDI
    expect(_.keys(view._diViews).length).toEqual 1
    spyOn(diView,"remove")
    view.remove()
    expect(diView.remove).toHaveBeenCalled()
    expect(_.keys(view._diViews).length).toEqual 0

  it "checks DI preserve class",->
    view1 = @view.getViewDI @TestViewDI
    view2 = @view.getViewDI @TestViewDI
    expect(view1).toEqual view2

  it "check DI precerve instace",->
    diView = new @TestViewDI
    view1 = @view.getViewDI diView
    expect(diView).toEqual view1
    view2 = @view.getViewDI diView
    expect(view1).toEqual view2

  it "check DI with options",->
    view1 = @view.getViewDI type:@TestViewDI, key:"1"
    view2 = @view.getViewDI type:@TestViewDI, key:"2"
    expect(view1).not.toEqual view2

describe "Check show functionality",->
  beforeEach ->
    TestView = MixinBackbone(Backbone.View).extend {
      initialize:->
        @render_counter = 0
      render:->
        @render_counter += 1

    }
    @view = new TestView
    @subview = new TestView

  afterEach ->
    @view.remove()

  it "check _currentView",->
    @view.show @subview
    expect(@view._currentView).toEqual @subview

  it "check exec close after show",->
    spyOn @view, "close"
    spyOn @view, "showViewAnimation"
    spyOn @subview, "render"
    @view.show @subview
    expect(@view.close).toHaveBeenCalled()
    expect(@view.showViewAnimation).toHaveBeenCalled()
    expect(@subview.render).toHaveBeenCalled()

  it "check not double exec rerender from subview",->
    spyOn @subview, "showViewAnimation"
    spyOn @subview, "closeViewAnimation"
    @view.show @subview
    expect(@subview.showViewAnimation).toHaveBeenCalled()
    @view.show @subview
    expect(@subview.closeViewAnimation).toHaveBeenCalled()
    expect(@subview.render_counter).toEqual 1

  it "check showAnimation",->
    spyOn @view, "showViewAnimation"
    @view.showAnimation()
    expect(@view.showViewAnimation).toBeTruthy()

  it "check closeAnimation",->
    spyOn @view, "closeViewAnimation"
    @view.showAnimation()
    expect(@view.closeViewAnimation).toBeTruthy()

  it "check close parent and close child",->
    @view.show @subview
    spyOn @subview, "closeViewAnimation"
    @view.close @view
    expect(@subview.closeViewAnimation).toHaveBeenCalled()

  it "check close parent and close child region",->    
    onCloseCounter = 0
    onShowCounter = 0
    SuperClass = MixinBackbone(Backbone.View)
    RegionView = SuperClass.extend 
      onClose:->
        onCloseCounter += 1
      onShow:->
        onShowCounter += 1
    SubView = SuperClass.extend 
      regions: test: el:".test", view: RegionView

    subview = new SubView
    @view.show subview

    spyOn subview, "closeViewAnimation"
    spyOn subview.test, "closeViewAnimation"
    expect(onShowCounter).toEqual 1
    @view.close @view
    expect(subview.closeViewAnimation).toHaveBeenCalled()
    expect(subview.test.closeViewAnimation).toHaveBeenCalled()
    expect(onCloseCounter).toEqual 1

    @view.show subview
    expect(onShowCounter).toEqual 2
    expect(onCloseCounter).toEqual 1
    subview.remove()

  it "render regions after render base view",->
    SuperClass = MixinBackbone(Backbone.View)

    RegionView = SuperClass.extend {}
      
    SubView = SuperClass.extend 
      regions: test: el:".test", view: RegionView

    subview = new SubView
    spyOn subview, "render"
    spyOn subview.test, "render"
    @view.show subview
    expect(subview.render).toHaveBeenCalled()
    expect(subview.test.render).toHaveBeenCalled()

  it "check setNeedRerender functionality",->
    spyOn @view, "setNeedRerenderView"
    @view.setNeedRerender()
    expect(@view.setNeedRerenderView).toHaveBeenCalled()

  it "check setNeedRerender",->
    @view.show @subview
    @subview.setNeedRerender()
    @view.show @subview
    expect(@subview.render_counter).toEqual 2

describe "check functionality when setElement call",->
  beforeEach ->
    TestView = MixinBackbone(Backbone.View).extend
      ui:
        test:".test_template"
      events:
        "click @ui.test":"on_click"
      regions:
        test:".test_template"
      templateFunc:-> "<div class='test_template'><div>"
      initialize:->
        @click_counter = 0
      on_click:->
        @click_counter += 1

    @view = new TestView

  afterEach ->
    @view.remove()

  it "check ui",->
    @view.ui.test.trigger "click"
    expect(@view.click_counter).toEqual(1)
    @view.setElement $("<div>")
    @view.ui.test.trigger "click"
    expect(@view.click_counter).toEqual(2)

  it "check regions binding",->
    $old = @view.test.$el
    @view.setElement $("<div>")
    expect($old).not.toEqual @view.test.$el

  it "check template reload",->
    templateWithRegion = '<div class="test_template"><div></div></div>'
    expect(@view.$el.html()).toEqual templateWithRegion
    @view.setElement $("<div>")
    expect(@view.$el.html()).toEqual templateWithRegion
