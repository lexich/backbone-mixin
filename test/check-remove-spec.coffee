describe "MixinBackbone::remove",->
  beforeEach ->
    SuperClass = MixinBackbone(Backbone.View)
    @TestView = SuperClass.extend {
      el:"<div><div class='test'/></div>"
      regions:
        test:'.test'
      initialize:->
        @count_unbindRegions = 0
        @count_unbindUIElements = 0
      unbindRegions:->
        @count_unbindRegions += 1
        SuperClass::unbindRegions.apply this, arguments
      unbindUIElements:->
        @count_unbindUIElements += 1
        SuperClass::unbindUIElements.apply this, arguments
    }
    @view = new @TestView

  afterEach ->
    @view.remove()

  it "check double remove",->    
    expect(false).toBe @view._$_p.removeFlag
    expect(0).toBe @view.count_unbindRegions
    expect(0).toBe @view.count_unbindUIElements


    @view.remove()
    expect(true).toBe @view._$_p.removeFlag
    expect(1).toBe @view.count_unbindRegions
    expect(1).toBe @view.count_unbindUIElements

    @view.remove()
    expect(true).toBe @view._$_p.removeFlag
    expect(1).toBe @view.count_unbindRegions
    expect(1).toBe @view.count_unbindUIElements

  it "check temove diViews",->
    expect(0).toBe _.chain(@view._$_p.diViews).keys().size().value()
    remove_di = 0
    @view._$_p.diViews = {
      test: new (Backbone.View.extend
        remove:->
          remove_di += 1
          Backbone.View::remove.apply this, arguments
      )
    }

    expect(0).toBe remove_di
    expect(1).toBe _.chain(@view._$_p.diViews).keys().size().value()

    @view.remove()
    expect(0).toBe _.chain(@view._$_p.diViews).keys().size().value()
    expect(1).toBe remove_di
    
    @view.remove()
    expect(0).toBe _.chain(@view._$_p.diViews).keys().size().value()
    expect(1).toBe remove_di
    

  it 'check remove subItems',->
    expect(null).not.toBe @view.r.test
    remove = @view.r.test.remove
    remove_count = 0
    @view.r.test.remove = =>
      remove_count += 1
      remove.apply @view.r.test, arguments
    expect(0).toBe remove_count
    
    @view.remove()
    expect(1).toBe remove_count
    
    @view.remove()
    expect(1).toBe remove_count
