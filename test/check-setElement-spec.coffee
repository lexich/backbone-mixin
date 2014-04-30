describe "check functionality when setElement call",->
  beforeEach ->
    TestView = MixinBackbone(Backbone.View).extend
      className:"testClass"
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
    expect(true).toEqual @view.$el.hasClass "testClass"
    @view.ui.test.trigger "click"
    expect(1).toEqual @view.click_counter
    @view.setElement $("<div>")
    expect(true).toEqual @view.$el.hasClass "testClass"
    @view.ui.test.trigger "click"
    expect(2).toEqual @view.click_counter

  it "check regions binding",->
    $old = @view.r.test.$el
    $new = $("<div>")
    @view.setElement $new
    expect($old).not.toEqual @view.r.test.$el    

  it "check template reload",->
    templateWithRegion = '<div class="test_template"><div></div></div>'
    expect(@view.$el.html()).toEqual templateWithRegion
    @view.setElement $("<div>")
    expect(@view.$el.html()).toEqual templateWithRegion