MixinBackbone = (Backbone)->
  MixinBackbone = (BaseClass)->
    BaseClass.extend
      _diViews:{}

      _currentView:null

      setElement:->
        BaseClass::setElement.apply this, arguments
        @__$_$removeFlag = false
        @reloadTemplate()
        @bindUIElements()
        @bindRegions()
        @bindUIEpoxy()

      remove:->
        if @__$_$removeFlag is true then return this else @__$_$removeFlag = true
        BaseClass::remove.apply this, arguments
        @unbindRegions()
        @unbindUIElements()
        _.each @_diViews,(view)->
          view.remove()
        @_diViews = {}

      delegateEvents:(events)->
        events or (events = _.result(this,'events'))
        if @__bindUIElements? and events?
          events = _.reduce events, ((memo, v,k)=>
            result = k.match(/@ui\.[^ ,]+/g)
            if result? then for part in result
              if /@ui\.([^ ,]+)/.exec(part)?
                selector = @__bindUIElements[RegExp.$1]
                k = k.replace part, selector
            memo[k] = v
            memo
          ),{}
        BaseClass::delegateEvents?.call this, events

      setNeedRerenderView:(view)->
        view._$_oneShow = null

      setNeedRerender:->
        @setNeedRerenderView this

      show:(view, options = {})->
        return unless view?
        if this isnt @_currentView
          @close @_currentView
        else
          @_currentView = null
        view = @getViewDI view, options
        @_currentView = view
        @$el.append view.$el
        unless view._$_oneShow?
          view._$_oneShow = true
          view.render?()
        view.onBeforeShow?()
        if view.regions?
          _.each view.regions, (v,k)->
            view[k].show view[k]
        @showViewAnimation view
        view.onShow?()
        view

      close:(view)->
        return unless view?
        if @_currentView? and @_currentView isnt view
          @close @_currentView 
        @_currentView = null
        #close regions
        if view.regions?
          _.each view.regions, (v,k)->
            reg = view[k]
            reg.close reg

        view.onBeforeClose?()
        @closeViewAnimation(view)
        view.onClose?()

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
          @_diViews[key] = ViewClass
        else if typeof(ViewClass) is "function"
          TypeView = ViewClass
          key = TypeView::_$_di or (TypeView::_$_di = _.uniqueId("_$_di"))
        else
          TypeView = ViewClass.type
          TypeView::_$_di or (TypeView::_$_di = _.uniqueId("_$_di"))
          key =  ViewClass.key
        unless @_diViews[key]?
          @_diViews[key] = new TypeView options
        @_diViews[key]

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
        _.each @regions,(v,k)=>
          this[k].remove()
          delete this[k]

      bindRegions:->
        return unless @regions
        _.each @regions,(v,k)=>
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
        @__bindUIElements = _.extend {}, @ui
        @ui = {}
        _.each @__bindUIElements,(v,k,ui)=>
          @ui[k] = @$el.find v

      unbindUIElements:->
        return unless @__bindUIElements?
        @ui = _.extend {}, @__bindUIElements

      bindUIEpoxy:->
        return unless @bindings
        @unbindUIEpoxy()
        @__bindings = @bindings
        rx = /@ui\.([^ ]+)/
        @bindings = _.reduce @__bindings, ((memo, v,k)=>
          if rx.exec(k)?
            selector = @__bindUIElements[RegExp.$1]
            key = k.replace rx, selector
            memo[key] = v
          else
            memo[k] = v
          memo
        ),{}

      unbindUIEpoxy:->
        return unless @__bindings?
        @bindings = _.extend {}, @__bindings

  Region = MixinBackbone(Backbone.View).extend {}

  MixinBackbone


if (typeof define is 'function') and (typeof define.amd is 'object') and define.amd
  define ["backbone"], (Backbone)-> MixinBackbone(Backbone)
else
  window.MixinBackbone = MixinBackbone(Backbone)
