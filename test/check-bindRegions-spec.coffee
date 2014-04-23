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