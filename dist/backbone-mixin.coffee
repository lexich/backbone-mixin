MixinBackbone = (Backbone)->
  MixinBackbone = (BaseClass)->
    currentView = null
    diViews = {}
    removeFlag = false
    varbindUIElements = null
    var_bindings = null

    BaseClass.extend      

      setElement:->
        BaseClass::setElement.apply this, arguments        
        @reloadTemplate()
        @bindUIElements()
        @bindRegions()
        @bindUIEpoxy()

      remove:->
        if removeFlag is true then return this else removeFlag = true
        BaseClass::remove.apply this, arguments
        @unbindRegions()
        @unbindUIElements()
        view.remove() for k,view of diViews
        diViews = {}

      _diViewsKeys:-> _.keys(diViews)
      _diViewsValues:-> _.values(diViews)

      delegateEvents:(events)->
        events or (events = _.result(this,'events'))
        if varbindUIElements? and events?
          events = _.reduce events, ((memo, v,k)=>
            result = k.match(/@ui\.[^ ,]+/g)
            if result? then for part in result
              if /@ui\.([^ ,]+)/.exec(part)?
                selector = varbindUIElements[RegExp.$1]
                k = k.replace part, selector
            memo[k] = v
            memo
          ),{}
        BaseClass::delegateEvents?.call this, events

      setNeedRerenderView:(view)->
        view._$_oneShow = null

      setNeedRerender:->
        @setNeedRerenderView this

      show:(_view, options = {})->
        return unless _view?
        if this isnt currentView
          @close currentView
        else
          currentView = null
        view = @getViewDI _view, options
        if this isnt view
          currentView = view
        @$el.append view.$el
        view.showCurrent()        
        view

      showCurrent:->
        unless @_$_oneShow?
          @_$_oneShow = true
          @render?()
        _.result(this,"onBeforeShow")
        if(regions = _.result(this,"regions"))
          _.each regions, (v,k)=> this[k].showCurrent()
        @showAnimation()
        _.result(this,"onShow")
        
      closeCurrent:->
        if(regions = _.result(this,"regions"))
          _.each regions, (v,k)=> this[k].closeCurrent()        
        _.result(this,"onBeforeClose")
        @closeAnimation()                
        _.result(this,"onClose")

      close:(_view)->
        return unless _view?
        if currentView? and currentView isnt _view
          @close currentView 
        currentView = null
        _view.closeCurrent()
        _view

      showAnimation:->
        @showViewAnimation this

      closeAnimation:->
        @closeViewAnimation this

      showViewAnimation:(view)->
        return unless view?
        if view.showAnimation? and view isnt this
          view.showAnimation()
        else
          view.$el.show()

      closeViewAnimation:(view)->
        return unless view?
        if view.closeAnimation? and view isnt this
          view.closeAnimation()
        else
          view.$el.hide()

      getViewDI:(ViewClass, options = {})->
        if ViewClass.cid?
          TypeView = ViewClass.constructor
          key = ViewClass.cid
          diViews[key] = ViewClass
        else if typeof(ViewClass) is "function"
          TypeView = ViewClass
          key = TypeView::_$_di or (TypeView::_$_di = _.uniqueId("_$_di"))
        else
          TypeView = ViewClass.type
          TypeView::_$_di or (TypeView::_$_di = _.uniqueId("_$_di"))
          key =  ViewClass.key
        unless diViews[key]?
          diViews[key] = new TypeView options
        diViews[key]

      reloadTemplate:->
        template = null
        data = null

        if @template?
          $el = $(@template)
          return unless !!$el.length
          template = $el.html()

        if @templateData?
          data = _.result(this,"templateData")
          @templateFunc? or @templateFunc = _.template

        if @templateFunc?
          @$el.html @templateFunc(template, data)
        else if template?
          @$el.html template

      unbindRegions:->
        return unless @regions
        for k,v of @regions        
          this[k].remove()
          delete this[k]

      bindRegions:->
        return unless @regions
        for k,v of @regions
          if _.isObject(v)
            el = if _.isString(v.el)
              @$el.find(v.el)
            else
              el = v.el
            View = v.view
          else
            el = @$el.find(v)
            View = Region

          if this[k]? then this[k].setElement el
          else this[k] = new View {el}

      bindUIElements:->
        return unless @ui?
        @unbindUIElements()
        varbindUIElements = _.extend {}, @ui
        @ui = {}
        for k, v of varbindUIElements        
          @ui[k] = @$el.find v

      unbindUIElements:->
        return unless varbindUIElements?
        @ui = varbindUIElements
        varbindUIElements = null

      bindUIEpoxy:->
        return unless @bindings
        @unbindUIEpoxy()
        var_bindings = @bindings
        rx = /@ui\.([^ ]+)/
        @bindings = _.reduce var_bindings, ((memo, v,k)=>
          if rx.exec(k)?
            selector = varbindUIElements[RegExp.$1]
            key = k.replace rx, selector
            memo[key] = v
          else
            memo[k] = v
          memo
        ),{}

      unbindUIEpoxy:->
        return unless var_bindings?
        @bindings = var_bindings
        var_bindings = null

  Region = MixinBackbone(Backbone.View).extend {}

  MixinBackbone


if (typeof define is 'function') and (typeof define.amd is 'object') and define.amd
  define ["backbone"], (Backbone)-> MixinBackbone(Backbone)
else
  window.MixinBackbone = MixinBackbone(Backbone)
