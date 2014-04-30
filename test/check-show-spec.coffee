describe "Check show functionality:",->
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

  it "check exec close after show",->
    spyOn @subview, "showAnimation"
    spyOn @subview, "render"
    @view.show @subview
    expect(@subview.showAnimation).toHaveBeenCalled()
    expect(@subview.render).toHaveBeenCalled()

  it 'check double call the same view',->
    finish_counter = 0
    onShow = 0
    @subview.on "onShow",-> onShow += 1

    @view.show @subview,{},->
      finish_counter+= 1
    expect(1).toBe finish_counter
    expect(1).toBe onShow

    @view.show @subview,{},->
      finish_counter+= 1
    expect(2).toBe finish_counter
    expect(1).toBe onShow

  it "check not call close -> open for reopen view",->
    spyOn @subview, "closeCurrent"
    @view.show @subview
    expect(@subview.closeCurrent).not.toHaveBeenCalled()
    @view.show @subview
    expect(@subview.closeCurrent).not.toHaveBeenCalled()
    @view.close @subview
    expect(@subview.closeCurrent).toHaveBeenCalled()

  it "check triggers",->
    bRender = 0
    onBeforeShow = 0
    onShow = 0
    onBeforeClose= 0
    onClose = 0
    @subview.on "onBeforeShow",-> onBeforeShow +=1
    @subview.on "render",->  bRender+= 1
    @subview.on "onShow",-> onShow+= 1
    @subview.on "onBeforeClose",-> onBeforeClose+=1
    @subview.on "onClose",-> onClose+=1
    @view.show @subview
    expect(bRender).toEqual 1
    expect(onBeforeShow).toEqual 1
    expect(onShow).toEqual 1

    @view.close @subview
    expect(onBeforeClose).toEqual 1
    expect(onClose).toEqual 1

  it "check not double exec rerender from subview",->
    spyOn @subview, "showViewAnimation"
    spyOn @subview, "closeViewAnimation"
    @view.show @subview
    expect(@subview.showViewAnimation).toHaveBeenCalled()
    @view.show @subview
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
    expect(onShowCounter).toEqual 1
    @view.close @view
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
    spyOn subview.r.test, "render"
    @view.show subview
    expect(subview.render).toHaveBeenCalled()
    expect(subview.r.test.render).toHaveBeenCalled()

  it "check setNeedRerender functionality",->
    spyOn @view, "setNeedRerenderView"
    @view.setNeedRerender()
    expect(@view.setNeedRerenderView).toHaveBeenCalled()

  it "check setNeedRerender",->
    @view.show @subview
    @subview.setNeedRerender()
    @view.close @subview
    @view.show @subview
    expect(@subview.render_counter).toEqual 2