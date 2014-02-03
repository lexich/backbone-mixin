var MixinBackbone;

MixinBackbone = (function() {
  var Region;
  MixinBackbone = function(BaseClass) {
    return BaseClass.extend({
      _diViews: {},
      _currentView: null,
      setElement: function() {
        BaseClass.prototype.setElement.apply(this, arguments);
        this.__$_$removeFlag = false;
        this.reloadTemplate();
        this.unbindUIElements();
        this.bindUIElements();
        this.bindRegions();
        return this.bindUIEpoxy();
      },
      remove: function() {
        if (this.__$_$removeFlag === true) {
          return this;
        } else {
          this.__$_$removeFlag = true;
        }
        BaseClass.prototype.remove.apply(this, arguments);
        this.unbindRegions();
        this.unbindUIElements();
        _.each(this._diViews, function(view) {
          return view.remove();
        });
        return this._diViews = {};
      },
      delegateEvents: function(events) {
        var _ref;
        events || (events = _.result(this, 'events'));
        if ((this.__bindUIElements != null) && (events != null)) {
          events = _.reduce(events, ((function(_this) {
            return function(memo, v, k) {
              var part, result, selector, _i, _len;
              result = k.match(/@ui\.[^ ,]+/g);
              if (result != null) {
                for (_i = 0, _len = result.length; _i < _len; _i++) {
                  part = result[_i];
                  if (/@ui\.([^ ,]+)/.exec(part) != null) {
                    selector = _this.__bindUIElements[RegExp.$1];
                    k = k.replace(part, selector);
                  }
                }
              }
              memo[k] = v;
              return memo;
            };
          })(this)), {});
        }
        return (_ref = BaseClass.prototype.delegateEvents) != null ? _ref.call(this, events) : void 0;
      },
      setNeedRerenderView: function(view) {
        return view._$_oneShow = null;
      },
      setNeedRerender: function() {
        return this.setNeedRerenderView(this);
      },
      show: function(view, options) {
        if (options == null) {
          options = {};
        }
        this.close(this._currentView);
        view = this.getViewDI(view, options);
        this._currentView = view;
        this.$el.append(view.$el);
        if (view._$_oneShow == null) {
          view._$_oneShow = true;
          if (typeof view.render === "function") {
            view.render();
          }
        }
        this.showViewAnimation(view);
        return view;
      },
      close: function(view) {
        return this.closeViewAnimation(view);
      },
      showAnimation: function() {
        return this.showViewAnimation(this);
      },
      closeAnimation: function() {
        return this.closeViewAnimation(this);
      },
      showViewAnimation: function(view) {
        if (view == null) {
          return;
        }
        if ((view.showAnimation != null) && view !== this) {
          return view.showAnimation();
        } else {
          return view.$el.show();
        }
      },
      closeViewAnimation: function(view) {
        if (view == null) {
          return;
        }
        if ((view.closeAnimation != null) && view !== this) {
          return view.closeAnimation();
        } else {
          return view.$el.hide();
        }
      },
      getViewDI: function(ViewClass, options) {
        var TypeView, key;
        if (options == null) {
          options = {};
        }
        if (ViewClass.cid != null) {
          TypeView = ViewClass.constructor;
          key = ViewClass.cid;
          this._diViews[key] = ViewClass;
        } else if (typeof ViewClass === "function") {
          TypeView = ViewClass;
          key = TypeView.prototype._$_di || (TypeView.prototype._$_di = _.uniqueId("_$_di"));
        } else {
          TypeView = ViewClass.type;
          TypeView.prototype._$_di || (TypeView.prototype._$_di = _.™uniqueId("_$_di"));
          key = ViewClass.key;
        }
        if (this._diViews[key] == null) {
          this._diViews[key] = new TypeView(options);
        }
        return this._diViews[key];
      },
      reloadTemplate: function() {
        var $el, data, template;
        template = null;
        data = null;
        if (this.template != null) {
          $el = $(this.template);
          if (!$el.length) {
            return;
          }
          template = $el.html();
        }
        if (this.templateData != null) {
          data = _.result(this, "templateData");
          (this.templateFunc != null) || (this.templateFunc = _.template);
        }
        if (this.templateFunc != null) {
          return this.$el.html(this.templateFunc(template, data));
        } else if (template != null) {
          return this.$el.html(template);
        }
      },
      unbindRegions: function() {
        if (!this.regions) {
          return;
        }
        return _.each(this.regions, (function(_this) {
          return function(v, k) {
            _this[k].remove();
            return delete _this[k];
          };
        })(this));
      },
      bindRegions: function() {
        if (!this.regions) {
          return;
        }
        return _.each(this.regions, (function(_this) {
          return function(v, k) {
            var el;
            el = _this.$el.find(v);
            if (_this[k] != null) {
              return _this[k].setElement(el);
            } else {
              return _this[k] = new Region({
                el: el
              });
            }
          };
        })(this));
      },
      bindUIElements: function() {
        if (this.ui == null) {
          return;
        }
        this.__bindUIElements = _.extend({}, this.ui);
        this.ui = {};
        return _.each(this.__bindUIElements, (function(_this) {
          return function(v, k, ui) {
            return _this.ui[k] = _this.$el.find(v);
          };
        })(this));
      },
      unbindUIElements: function() {
        if (this.__bindUIElements == null) {
          return;
        }
        return this.ui = _.extend({}, this.__bindUIElements);
      },
      bindUIEpoxy: function() {
        var rx;
        if (!this.bindings) {
          return;
        }
        this.__bindings = this.bindings;
        rx = /@ui\.([^ ]+)/;
        return this.bindings = _.reduce(this.__bindings, ((function(_this) {
          return function(memo, v, k) {
            var key, selector;
            if (rx.exec(k) != null) {
              selector = _this.__bindUIElements[RegExp.$1];
              key = k.replace(rx, selector);
              memo[key] = v;
            } else {
              memo[k] = v;
            }
            return memo;
          };
        })(this)), {});
      }
    });
  };
  Region = MixinBackbone(Backbone.View).extend({});
  return MixinBackbone;
})();

if ((typeof define === 'function') && (typeof define.amd === 'object') && define.amd) {
  define([], function() {
    return MixinBackbone;
  });
} else {
  window.MixinBackbone = MixinBackbone;
}
