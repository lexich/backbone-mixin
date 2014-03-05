MixinBackbone = (Backbone)->
  MixinBackbone = (BaseClass)->
    BaseClass.extend
      version:"0.0.0"
      # @overwrite default Backbone method Backbone.View.setElement      
      setElement:->
        unless @_$_p?
          @_$_p =
            currentView:null
            diViews:{}
            removeFlag:false
            varbindUIElements:null
            var_bindings:null
        BaseClass::setElement.apply this, arguments
        @$el.addClass @className if @className?          
        @reloadTemplate()
        @bindUIElements()
        @bindRegions()
        @bindUIEpoxy()

      # @overwrite default Backbone method Backbone.View.remove   
      remove:->
        if @_$_p.removeFlag is true then return this else @_$_p.removeFlag = true
        BaseClass::remove.apply this, arguments
        @unbindRegions()
        @unbindUIElements()
        view.remove() for k,view of @_$_p.diViews
        @_$_p.diViews = {}

      # @overwrite default Backbone method Backbone.View.delegateEvents
      delegateEvents:(events)->
        events or (events = _.result(this,'events'))
        if @_$_p.varbindUIElements? and events?
          events = _.reduce events, ((memo, v,k)=>
            result = k.match(/@ui\.[^ ,]+/g)
            if result? then for part in result
              if /@ui\.([^ ,]+)/.exec(part)?
                selector = @_$_p.varbindUIElements[RegExp.$1]
                k = k.replace part, selector
            memo[k] = v
            memo
          ),{}
        BaseClass::delegateEvents?.call this, events

      # Get keys of all DI views
      _diViewsKeys:-> _.keys(@_$_p.diViews)

      # Get all DI views
      _diViewsValues:-> _.values(@_$_p.diViews)

      # `show` mechanizm call `view.render` function only while first calling. `setNeedRerenderView` forse call `view.render` function once again
      setNeedRerenderView:(view)->
        view._$_oneShow = null

      # Alias setNeedRerenderView(this)
      setNeedRerender:->
        @setNeedRerenderView this

      _setCurrentView:(view)-> @_$_p.currentView = view

      show:(_view, options = {})->
        return unless _view?
        view = @getViewDI _view, options
        return view if view is @_$_p.currentView
        @close @_$_p.currentView if @_$_p.currentView? and this isnt @_$_p.currentView
        @_setCurrentView null
        if this isnt view
          @_setCurrentView view
        @$el.append view.$el
        view.showCurrent()
        view

      showCurrent:->
        this.trigger "onBeforeShow"
        @onBeforeShow?()
        unless @_$_oneShow?
          @_$_oneShow = true
          this.trigger "render"
          @render()
        if(regions = _.result(this,"regions"))
          for k,v of regions
            this[k].showCurrent()
        if @_$_p.currentView? and @_$_p.currentView isnt this
          @_$_p.currentView.showCurrent()
        @showAnimation()
        this.trigger "onShow"
        @onShow?()

      closeCurrent:->
        this.trigger "onBeforeClose"
        @onBeforeClose?()
        if(regions = _.result(this,"regions"))
          for k,v of regions
            this[k].closeCurrent()
        if @_$_p.currentView? and @_$_p.currentView isnt this
          @_$_p.currentView.closeCurrent()
        @closeAnimation()
        this.trigger "onClose"
        @onClose?()

      close:(_view)->
        return unless _view?
        @close @_$_p.currentView  if @_$_p.currentView? and @_$_p.currentView isnt _view
        @_setCurrentView null
        _view.closeCurrent()
        _view

      # Alias showViewAnimation(this)
      showAnimation:->
        @showViewAnimation this

      # Alias closeViewAnimation(this)
      closeAnimation:->
        @closeViewAnimation this

      # Helper method which can descride animation/behavior for `view` while base view `show` `view`. By default using `view.$el.show()`
      showViewAnimation:(view)->
        return unless view?
        if view.showAnimation? and view isnt this
          view.showAnimation()
        else
          view.$el.show()
      # Helper method which can descride animation/behavior for `view` while base view `close` `view`. By default using `view.$el.show()`
      closeViewAnimation:(view)->
        return unless view?
        if view.closeAnimation? and view isnt this
          view.closeAnimation()
        else
          view.$el.hide()

      # Depedencies Injection functionality
      # `options` - options for `new View(options)`  operations
      # `ViewParams`
      #  - type `Backbone.View` - if you use this View only once in ypu application
      #  - type `instance Backbone.View` - if you save instance ny ViewParams.cid
      #  - type `object` - usefull for multiple using Views
      #    - type: `Backbone.View` - View prototype
      #    - key: `String` - key for different instace
      getViewDI:(ViewClass, options = {})->
        if ViewClass.cid?
          TypeView = ViewClass.constructor
          key = ViewClass.cid
          @_$_p.diViews[key] = ViewClass
        else if typeof(ViewClass) is "function"
          TypeView = ViewClass
          key = TypeView::_$_di or (TypeView::_$_di = _.uniqueId("_$_di"))
        else
          TypeView = ViewClass.type
          TypeView::_$_di or (TypeView::_$_di = _.uniqueId("_$_di"))
          key =  ViewClass.key
        unless @_$_p.diViews[key]?
          @_$_p.diViews[key] = new TypeView options
        @_$_p.diViews[key]

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
            View = MixinBackbone(Backbone.View)

          if this[k]? then this[k].setElement el
          else this[k] = new View {el}

      bindUIElements:->
        return unless @ui?
        @unbindUIElements()
        @_$_p.varbindUIElements = _.extend {}, @ui
        @ui = {}
        for k, v of @_$_p.varbindUIElements
          @ui[k] = @$el.find v

      unbindUIElements:->
        return unless @_$_p.varbindUIElements?
        @ui = @_$_p.varbindUIElements
        @_$_p.varbindUIElements = null

      bindUIEpoxy:->
        return unless @bindings
        @unbindUIEpoxy()
        @_$_p.var_bindings = @bindings
        rx = /@ui\.([^ ]+)/
        @bindings = _.reduce @_$_p.var_bindings, ((memo, v,k)=>
          if rx.exec(k)?
            selector = @_$_p.varbindUIElements[RegExp.$1]
            key = k.replace rx, selector
            memo[key] = v
          else
            memo[k] = v
          memo
        ),{}

      unbindUIEpoxy:->
        return unless @_$_p.var_bindings?
        @bindings = @_$_p.var_bindings
        @_$_p.var_bindings = null

  MixinBackbone

# AMD support
if (typeof define is 'function') and (typeof define.amd is 'object') and define.amd
  define ["backbone"], (Backbone)-> MixinBackbone(Backbone)
else
  window.MixinBackbone = MixinBackbone(Backbone)
