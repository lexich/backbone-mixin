describe "Check MixinBackbone bindRegions and bindUI", ->
  beforeEach ->
    @TestView = MixinBackbone(Backbone.View).extend
      el:"<div><div class='test'/></div>"
      ui:
        test:".test"

      regions:
        test_region:"@ui.test"

    @view = new @TestView

  afterEach ->
    @view.remove()


  it "check bindings",->
    expect(1).toEqual @view.ui.test.length
    expect(!!@view.r.test_region).toBeTruthy()
    expect(1).toEqual @view.r.test_region.$el.length
    expect(@view.ui.test[0]).toEqual @view.r.test_region.el