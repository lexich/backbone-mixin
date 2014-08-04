MixinBackbone = (Backbone)->
  MixinBackbone.version = "0.3.2"
  MixinBackbone = (BaseClass)->
    BaseClass.extend
      constructor:(options)->
        @_$_options = options        
        BaseClass::constructor?.apply this, arguments
        delete @_$_options

      #
      # @lang=en overwrite default Backbone method Backbone.View.setElement
      #
      # @lang=ru Перегрузка стандартного метода Backbone.View.setElement
      #
      setElement:->
        unless @_$_p?
          @_$_p =
            currentView:null
            diViews:{}
            removeFlag:false
            varbindUIElements:null
            var_bindings:null
        BaseClass::setElement.apply this, arguments
        @scope? @_$_options
        @$el.addClass @className if @className?
        @reloadTemplate()
        @bindUIElements()
        @bindRegions()
        @bindUIEpoxy()
      #
      # @lang=en overwrite default Backbone method Backbone.View.remove
      #
      # @lang=ru Перегрузка стандартного метода Backbone.View.remove
      #
      remove:->
        if @_$_p.removeFlag is true then return this else @_$_p.removeFlag = true
        BaseClass::remove.apply this, arguments
        @unbindRegions()
        @unbindUIElements()
        view.remove() for k,view of @_$_p.diViews
        @_$_p.diViews = {}
      #
      # @lang=en overwrite default Backbone method Backbone.View.delegateEvents
      #
      # @lang=ru Перегрузка стандартного метода Backbone.View.delegateEvents
      #
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
      #
      # @lang=en Helper helps listen obj for name change
      # and callback for current value
      #
      # @lang=ru Хелпер позволяет повесить слушателя на obj 
      # на измение значения name и сразу же вызвать callback для текущего значения
      #
      listenToValue:(obj, _name, callback) ->
        if /change:(.+)/.exec _name
          name = RegExp.$1
        else
          name = _name
        @listenTo obj, "change:#{name}", callback        
        setTimeout (=>
          callback.call this, obj, obj.get(name),{}
        ), 0
      #
      # @lang=en Get keys of all DI views
      #
      # @lang=ru Получение всех ключей из DI-кэша
      #
      _diViewsKeys:-> _.keys(@_$_p.diViews)

      #
      # @lang=en Get all DI views
      #
      # @lang=ru Получение всех значений из DI-кэша
      #
      _diViewsValues:-> _.values(@_$_p.diViews)

      #
      # @lang=en `show` mechanizm call `view.render` function only while first calling.
      # `setNeedRerenderView` forse call `view.render` function once again
      #
      # @lang=ru Метод устанавливает флаг, который позволяет при вызове `show(view)`
      # повторно вызвать метод `render`
      #
      setNeedRerenderView:(view)->
        view._$_oneShow = null

      #
      # @lang=en Alias setNeedRerenderView(this)
      #
      # @lang=ru Псевдоним конструкции
      #
      setNeedRerender:->
        @setNeedRerenderView this

      #
      # @lang=en private method to set current open view
      #
      # @lang=ru приватный метод для установки текущей открытой view
      #
      _setCurrentView:(view)->
        @_$_p.currentView = view

      #
      # @lang=en
      #
      # @lang=ru
      #

      show:(_view, options = {},callback)->
        unless _view?
          callback?()
          return
        view = @getViewDI _view, options
        if view is @_$_p.currentView
          callback?()
          return view
        __show = =>
            @_setCurrentView null
            if this isnt view
              @_setCurrentView view
            @$el.append view.$el
            view.showCurrent callback
            view

        if @_$_p.currentView? and this isnt @_$_p.currentView
          @close @_$_p.currentView, __show
        else
          __show()
        view

      showCurrent:(callback)->
        this.trigger "onBeforeShow"
        @onBeforeShow?()
        unless @_$_oneShow?
          @_$_oneShow = true
          this.trigger "render"
          @render()

        finish = _.after 3, => callback?()              #--finish 3 times

        if(regions = _.result(this,"regions"))
          keys = _.keys(regions)
          _callback = _.after _.size(keys), finish      #->finish 1
          this.r[k].showCurrent _callback for k in keys
        else
          finish()                                      #->finish 1

        if @_$_p.currentView? and @_$_p.currentView isnt this
          @_$_p.currentView.showCurrent finish          #->finish 2
        else
          finish()                                      #->finish 2

        @showAnimation =>
          @trigger "onShow"
          @onShow?()
          finish()                                      #->finish 3

      closeCurrent:(callback)->
        this.trigger "onBeforeClose"
        @onBeforeClose?()
        finish = _.after 3, =>  callback?()             #--finish 3 times

        if(regions = _.result(this,"regions"))
          keys = _.keys(regions)
          _callback = _.after _.size(keys), finish      #->finish 1
          this.r[k].closeCurrent _callback for k in keys
        else
          finish()                                      #->finish 1

        if @_$_p.currentView? and @_$_p.currentView isnt this
          @_$_p.currentView.closeCurrent finish         #->finish 2
        else
          finish()                                      #->finish 2

        @closeAnimation =>
          @trigger "onClose"
          @onClose?()
          finish()                                      #->finish 3

      close:(_view, callback)->
        unless _view?
          callback?()
          return
        finish = _.after 2, => callback?()              #--finish 3 times
        if @_$_p.currentView? and @_$_p.currentView isnt _view
          @close @_$_p.currentView, finish
        else
          finish()

        @_setCurrentView null
        _view.closeCurrent finish
        _view

      # Alias showViewAnimation(this)
      showAnimation:(callback)->
        @showViewAnimation this, callback

      # Alias closeViewAnimation(this)
      closeAnimation:(callback)->
        @closeViewAnimation this, callback

      # Helper method which can descride animation/behavior for `view` while base view `show` `view`. By default using `view.$el.show()`
      showViewAnimation:(view, callback)->
        unless view?
          callback?()
          return
        if view.showAnimation? and view isnt this
          view.showAnimation callback
        else
          view.$el.show()
          callback?()

      # Helper method which can descride animation/behavior for `view` while base view `close` `view`. By default using `view.$el.show()`
      closeViewAnimation:(view, callback)->
        unless view?
          callback?()
          return
        if view.closeAnimation? and view isnt this
          view.closeAnimation callback
        else
          view.$el.hide()
          callback?()

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
          continue if k is "__oldmode__"
          this.r[k].remove()
          delete this.r[k]
          if @regions.__oldmode__
            delete this[k]

      bindRegions:->
        @r ?= {}
        return unless @regions
        rx = /@ui\.([^ ]+)/
        isOldMode = _.isBoolean(@regions.__oldmode__) and @regions.__oldmode__
        for k,v of @regions
          continue if k is "__oldmode__"
          if _.isObject(v)
            el = if _.isString(v.el)
              @$el.find(v.el)
            else
              el = v.el
            View = v.view
          else
            if rx.exec(v)? and @ui[RegExp.$1]?
              el = @ui[RegExp.$1]
            else
              el = @$el.find(v)
            View = MixinBackbone(Backbone.View)

          if this.r[k]? 
            this.r[k].setElement el
          else 
            options = {el}
            if _.isFunction(v.scope)
              opt = v.scope.call this
              _.extend options, opt
            else if _.isObject(v.scope)
              _.extend options, v.scope
            this.r[k] = new View options
          this[k] = this.r[k] if isOldMode and not this[k]?

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
