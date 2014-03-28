var MixinBackbone;

MixinBackbone = function(Backbone) {
  MixinBackbone.version = "0.2.6";
  MixinBackbone = function(BaseClass) {
    return BaseClass.extend({
      setElement: function() {
        if (this._$_p == null) {
          this._$_p = {
            currentView: null,
            diViews: {},
            removeFlag: false,
            varbindUIElements: null,
            var_bindings: null
          };
        }
        BaseClass.prototype.setElement.apply(this, arguments);
        if (this.className != null) {
          this.$el.addClass(this.className);
        }
        this.reloadTemplate();
        this.bindUIElements();
        this.bindRegions();
        return this.bindUIEpoxy();
      },
      remove: function() {
        var k, view, _ref;
        if (this._$_p.removeFlag === true) {
          return this;
        } else {
          this._$_p.removeFlag = true;
        }
        BaseClass.prototype.remove.apply(this, arguments);
        this.unbindRegions();
        this.unbindUIElements();
        _ref = this._$_p.diViews;
        for (k in _ref) {
          view = _ref[k];
          view.remove();
        }
        return this._$_p.diViews = {};
      },
      delegateEvents: function(events) {
        var _ref;
        events || (events = _.result(this, 'events'));
        if ((this._$_p.varbindUIElements != null) && (events != null)) {
          events = _.reduce(events, ((function(_this) {
            return function(memo, v, k) {
              var part, result, selector, _i, _len;
              result = k.match(/@ui\.[^ ,]+/g);
              if (result != null) {
                for (_i = 0, _len = result.length; _i < _len; _i++) {
                  part = result[_i];
                  if (/@ui\.([^ ,]+)/.exec(part) != null) {
                    selector = _this._$_p.varbindUIElements[RegExp.$1];
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
      listenToValue: function(obj, name, callback) {
        obj.on(name, callback, this);
        return setTimeout(((function(_this) {
          return function() {
            return callback.call(_this, obj, obj.get(name));
          };
        })(this)), 0);
      },
      _diViewsKeys: function() {
        return _.keys(this._$_p.diViews);
      },
      _diViewsValues: function() {
        return _.values(this._$_p.diViews);
      },
      setNeedRerenderView: function(view) {
        return view._$_oneShow = null;
      },
      setNeedRerender: function() {
        return this.setNeedRerenderView(this);
      },
      _setCurrentView: function(view) {
        return this._$_p.currentView = view;
      },
      show: function(_view, options, callback) {
        var view, __show;
        if (options == null) {
          options = {};
        }
        if (_view == null) {
          return;
        }
        view = this.getViewDI(_view, options);
        if (view === this._$_p.currentView) {
          return view;
        }
        __show = (function(_this) {
          return function() {
            _this._setCurrentView(null);
            if (_this !== view) {
              _this._setCurrentView(view);
            }
            _this.$el.append(view.$el);
            view.showCurrent(callback);
            return view;
          };
        })(this);
        if ((this._$_p.currentView != null) && this !== this._$_p.currentView) {
          return this.close(this._$_p.currentView, __show);
        } else {
          return __show();
        }
      },
      showCurrent: function(callback) {
        var finish, k, keys, regions, _callback, _i, _len;
        this.trigger("onBeforeShow");
        if (typeof this.onBeforeShow === "function") {
          this.onBeforeShow();
        }
        if (this._$_oneShow == null) {
          this._$_oneShow = true;
          this.trigger("render");
          this.render();
        }
        finish = _.after(3, (function(_this) {
          return function() {
            return typeof callback === "function" ? callback() : void 0;
          };
        })(this));
        if ((regions = _.result(this, "regions"))) {
          keys = _.keys(regions);
          _callback = _.after(_.size(keys), finish);
          for (_i = 0, _len = keys.length; _i < _len; _i++) {
            k = keys[_i];
            this[k].showCurrent(_callback);
          }
        } else {
          finish();
        }
        if ((this._$_p.currentView != null) && this._$_p.currentView !== this) {
          this._$_p.currentView.showCurrent(finish);
        } else {
          finish();
        }
        return this.showAnimation((function(_this) {
          return function() {
            _this.trigger("onShow");
            if (typeof _this.onShow === "function") {
              _this.onShow();
            }
            return finish();
          };
        })(this));
      },
      closeCurrent: function(callback) {
        var finish, k, keys, regions, _callback, _i, _len;
        this.trigger("onBeforeClose");
        if (typeof this.onBeforeClose === "function") {
          this.onBeforeClose();
        }
        finish = _.after(3, (function(_this) {
          return function() {
            return typeof callback === "function" ? callback() : void 0;
          };
        })(this));
        if ((regions = _.result(this, "regions"))) {
          keys = _.keys(regions);
          _callback = _.after(_.size(keys), finish);
          for (_i = 0, _len = keys.length; _i < _len; _i++) {
            k = keys[_i];
            this[k].closeCurrent(_callback);
          }
        } else {
          finish();
        }
        if ((this._$_p.currentView != null) && this._$_p.currentView !== this) {
          this._$_p.currentView.closeCurrent(finish);
        } else {
          finish();
        }
        return this.closeAnimation((function(_this) {
          return function() {
            _this.trigger("onClose");
            if (typeof _this.onClose === "function") {
              _this.onClose();
            }
            return finish();
          };
        })(this));
      },
      close: function(_view, callback) {
        var finish;
        if (_view == null) {
          return;
        }
        finish = _.after(2, (function(_this) {
          return function() {
            return typeof callback === "function" ? callback() : void 0;
          };
        })(this));
        if ((this._$_p.currentView != null) && this._$_p.currentView !== _view) {
          this.close(this._$_p.currentView, finish);
        } else {
          finish();
        }
        this._setCurrentView(null);
        _view.closeCurrent(finish);
        return _view;
      },
      showAnimation: function(callback) {
        return this.showViewAnimation(this, callback);
      },
      closeAnimation: function(callback) {
        return this.closeViewAnimation(this, callback);
      },
      showViewAnimation: function(view, callback) {
        if (view == null) {
          return typeof callback === "function" ? callback() : void 0;
        }
        if ((view.showAnimation != null) && view !== this) {
          return view.showAnimation(callback);
        } else {
          view.$el.show();
          return typeof callback === "function" ? callback() : void 0;
        }
      },
      closeViewAnimation: function(view, callback) {
        if (view == null) {
          return typeof callback === "function" ? callback() : void 0;
        }
        if ((view.closeAnimation != null) && view !== this) {
          return view.closeAnimation(callback);
        } else {
          view.$el.hide();
          return typeof callback === "function" ? callback() : void 0;
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
          this._$_p.diViews[key] = ViewClass;
        } else if (typeof ViewClass === "function") {
          TypeView = ViewClass;
          key = TypeView.prototype._$_di || (TypeView.prototype._$_di = _.uniqueId("_$_di"));
        } else {
          TypeView = ViewClass.type;
          TypeView.prototype._$_di || (TypeView.prototype._$_di = _.uniqueId("_$_di"));
          key = ViewClass.key;
        }
        if (this._$_p.diViews[key] == null) {
          this._$_p.diViews[key] = new TypeView(options);
        }
        return this._$_p.diViews[key];
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
        var k, v, _ref, _results;
        if (!this.regions) {
          return;
        }
        _ref = this.regions;
        _results = [];
        for (k in _ref) {
          v = _ref[k];
          this[k].remove();
          _results.push(delete this[k]);
        }
        return _results;
      },
      bindRegions: function() {
        var View, el, k, v, _ref, _results;
        if (!this.regions) {
          return;
        }
        _ref = this.regions;
        _results = [];
        for (k in _ref) {
          v = _ref[k];
          if (_.isObject(v)) {
            el = _.isString(v.el) ? this.$el.find(v.el) : el = v.el;
            View = v.view;
          } else {
            el = this.$el.find(v);
            View = MixinBackbone(Backbone.View);
          }
          if (this[k] != null) {
            _results.push(this[k].setElement(el));
          } else {
            _results.push(this[k] = new View({
              el: el
            }));
          }
        }
        return _results;
      },
      bindUIElements: function() {
        var k, v, _ref, _results;
        if (this.ui == null) {
          return;
        }
        this.unbindUIElements();
        this._$_p.varbindUIElements = _.extend({}, this.ui);
        this.ui = {};
        _ref = this._$_p.varbindUIElements;
        _results = [];
        for (k in _ref) {
          v = _ref[k];
          _results.push(this.ui[k] = this.$el.find(v));
        }
        return _results;
      },
      unbindUIElements: function() {
        if (this._$_p.varbindUIElements == null) {
          return;
        }
        this.ui = this._$_p.varbindUIElements;
        return this._$_p.varbindUIElements = null;
      },
      bindUIEpoxy: function() {
        var rx;
        if (!this.bindings) {
          return;
        }
        this.unbindUIEpoxy();
        this._$_p.var_bindings = this.bindings;
        rx = /@ui\.([^ ]+)/;
        return this.bindings = _.reduce(this._$_p.var_bindings, ((function(_this) {
          return function(memo, v, k) {
            var key, selector;
            if (rx.exec(k) != null) {
              selector = _this._$_p.varbindUIElements[RegExp.$1];
              key = k.replace(rx, selector);
              memo[key] = v;
            } else {
              memo[k] = v;
            }
            return memo;
          };
        })(this)), {});
      },
      unbindUIEpoxy: function() {
        if (this._$_p.var_bindings == null) {
          return;
        }
        this.bindings = this._$_p.var_bindings;
        return this._$_p.var_bindings = null;
      }
    });
  };
  return MixinBackbone;
};

if ((typeof define === 'function') && (typeof define.amd === 'object') && define.amd) {
  define(["backbone"], function(Backbone) {
    return MixinBackbone(Backbone);
  });
} else {
  window.MixinBackbone = MixinBackbone(Backbone);
}
