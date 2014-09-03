describe "Check MixinBackbone bindRegions", ->
  it "check regions",->
    TestView = MixinBackbone(Backbone.View).extend
      regions:
        test:".test"
    view = new TestView()
    expect(!!view.regions).toBeTruthy()
    view.remove()
    expect(!view.r.test).toBeTruthy()

  it "check regions __oldmode__",->
    TestView = MixinBackbone(Backbone.View).extend
      regions:
        __oldmode__:true
        test:".test"
    view = new TestView()
    expect(view.regions.__oldmode__).toBeTruthy()
    expect(!!view.regions).toBeTruthy()
    expect(view.r.test).toBeTruthy()
    expect(view.test).toBeTruthy()
    expect(!view.r.__oldmode__).toBeTruthy()
    expect(!view.__oldmode__).toBeTruthy()
    view.remove()
    expect(!view.r.test).toBeTruthy()
    expect(!view.test).toBeTruthy() 

  it "check regions __oldmode__ work correct in shown view",->
    ContainerView = MixinBackbone(Backbone.View).extend {}
    TestView = MixinBackbone(Backbone.View).extend
      regions:
        __oldmode__:true
        test:".test"
    container = new ContainerView
    view = new TestView
    container.show view
    container.close view

  it "check bind regions with options", ->
    Model = Backbone.Model.extend {
      defaults:
        value:1
    }
    TestView = MixinBackbone(Backbone.View).extend
      el:"<div><div class='test /></div>"
      regions:
        test:
          el:".test"
          view: MixinBackbone(Backbone.View).extend {}
          scope:-> {@model}

      scope:->
        @model = new Model
    view = new TestView
    expect(!!view.r.test).toBeTruthy()
    expect(!!view.r.test.model).toBeTruthy()
    expect(1).toEqual view.r.test.model.get("value")
    view.remove()

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
    expect(!!view.r.test).toBeTruthy()
    expect(!!view.r.test.custom_region).toBeTruthy()
    test = view.r.test
    view.remove()
    expect(!view.r.test).toBeTruthy()
    expect(!!test.remove_custom_view).toBeTruthy()


  it "check custom regions with dom element",->
    RegionView = MixinBackbone(Backbone.View).extend {}
    $el = $("<div class='test'/>")
    TestView = MixinBackbone(Backbone.View).extend
      regions:
        test: el:$el, view:RegionView
    view = new TestView()
    expect(view.r.test.$el).toEqual($el)
    view.remove()