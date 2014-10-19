[docs](https://lexich.github.io/backbone-mixin/)

[![Build Status](https://travis-ci.org/lexich/backbone-mixin.png?branch=master)](https://travis-ci.org/lexich/backbone-mixin)
[![Bower version](https://badge.fury.io/bo/backbone-mixin.svg)](http://badge.fury.io/bo/backbone-mixin)
[![Coverage Status](https://coveralls.io/repos/lexich/backbone-mixin/badge.png?branch=master)](https://coveralls.io/r/lexich/backbone-mixin?branch=master)
# Description
Mixin for extend [Backbone.View](http://backbonejs.org/#View) or [Backbone.Epoxy.View](http://epoxyjs.org/documentation.html#view)  
Inspired by [Chalin](chaplinjs.org) and [Marionette](http://marionettejs.com/)  
It's not a framework, it's little mixin-helper for great arhitecture.

# Instalation
```
bower install backbone-mixin --save
```

#### ui  
Type `Object`  
Syntax sugar, define map of children dom elements.
```js
{
  ui: {
    test: ".container .test"  //definition
  },
  events: {
    "click @ui.test": "on_click_test" //using in event binding
  },
  bindings: {
    "@ui.test": "text:value" //using in Epoxy bindings http://epoxyjs.org/tutorials.html#simple-bindings
  },
  render: function(){
    this.ui.test.show(); //direct using
  }
}
```

#### template
Type `String`
Direct loading html template from DOM to current element (this.el)
```js
{
  template: "#Template"  
}

```
```html
<script id="Template" type="template/text">
<p>Template content</p>
</script>
```

#### templateFunc
Type `Function`
Function for process `template`. For expample you can use underscore template engine of handlebars etc.
```js
templateFunc: function(template,data){
  return _.template(template,data);
}
```

#### templateData
Type `Object` or `Function`
Data for template processing. If templateFunc isn't define and templateData define, then templateFunc use underscore template engine.

#### regions
Type `Object`
Sugar syntax for bingins subview. `regions` can be used for gluing current view with multiple other views
```js
regions: {
  hello: ".hello_selector"  
},
render: function(){
  //this.r.hello is BackboneMixin(Backbone.View) instance
  this.r.hello.show(CustomBackboneView); 
  //now instance of CustomBackboneVIew is subview of this.hello view
}
```
Also regions can use for point to point view bindings

```js
regions: {
  hello: {
    el: ".hello_selector",
    view: (HelloView = MixinBackbone(Backbone.View).extend({}))
  }
},
render: function(){
  this.r.hello.$el === this.$el.find(".hello_selector");
}
```
when view render with "show" mechanizm then all regions call render

before version 0.3.0 regions load to `this` scope after they load in `this.r` scope. For compatible with old code you can use `__oldmode__` flag. And `__oldmode__` can't be name of region

```js
regions: {
  __oldmode__: true,
  hello: ".hello_selector"
},
render: function(){
  this.r.hello === this.hello;
}
```

Also you can use `regions` and `ui` together
```js
ui: {
  test: ".test"
}
regions: {
  test: {
    el: "@ui.test",
    view: (HelloView = MixinBackbone(Backbone.View).extend({}))
  }
}
```

Using scope functionality
```js
regions: {
  test: {
  	el: ".test",
  	view: (HelloView = MixinBackbone(Backbone.View).extend({
	  initialize: function(options){
	    options.test === "test value";
	    this.model !== null;
	  }
	}
  	})),
  	scope: function(){
		//this context is context of view
		this.model !== null;
		this.collection === null; //initialize calls after scope
		return {
			model: this.model,
			test: "test value"
		};
  	}
  }
},
scope: function(){
	this.model = new TestModel();
},
initialize: function(){
	this.collection = new TestCollection();
}

```

#### show(view,options)
Type `Function`
Show view in current view. Very usefull for regions. This method append `view.el` to `this.el` and call helper method `this.showViewAnimation`

#### close(view)
Type `Function`
Close view which was opened in current view. This method not call `this.remove` by default, but call helper method `this.closeViewAnimation`

### setNeedRerenderView(view)
Type `Function`
`show` mechanizm call `view.render` function only while first calling. `setNeedRerenderView` forse call `view.render` function once again

#### setNeedRerender 
Type `Function`
Alias setNeedRerenderView(this)

#### showViewAnimation(view)
Type `Function`
Helper method which can descride animation/behavior for `view` while base view `show` `view`. By default using `view.$el.show()`

#### showAnimation
Type `Function`
Alias showViewAnimation(this)

#### closeViewAnimation(view)
Type `Function`
Helper method which can descride animation/behavior for `view` while base view `close` `view`. By default using `view.$el.show()`

#### closeAnimation
Type `Function`
Alias closeViewAnimation(this)

#### getViewDI(ViewParams, options)
Type `Function`
Depedencies Injection functionality
`options` - options for `new View(options)`  operations
`ViewParams`
  - type `Backbone.View` - if you use this View only once in ypu application
  - type `instance Backbone.View` - if you save instance ny ViewParams.cid
  - type `object` - usefull for multiple using Views
    - type: `Backbone.View` - View prototype
    - key: `String` - key for different instace

#### onShow
Type `Function`
callback caller,  execute when view base view `show` this view

#### onClose
Type `Function`
callback caller, execute when view base view `close` this view

#Run tests
```bash
npm install
bower install
grunt karma:dist
```



[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/lexich/backbone-mixin/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

