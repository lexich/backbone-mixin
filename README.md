[![Build Status](https://travis-ci.org/lexich/backbone-mixin.png?branch=master)](https://travis-ci.org/lexich/backbone-mixin)
# Documention in processs

#### ui  
Type `Object`  
Syntax sugar, define map of children dom elements.
```js
{
  ui:{
    test:".container .test"  //definition
  },
  event:{
    "click ui.test":"on_click_test" //using in event binding
  },
  bindings:{
    "ui.test":"text:value" //using in Epoxy bindings http://epoxyjs.org/tutorials.html#simple-bindings
  },
  render:function(){
    this.ui.test.show(); //direct using
  }
}
```

#### template
Type `String`
Direct load html template from DOM to current element
```js
template:"#Template"
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
templateFunc:function(template,data){
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
regions:{
  "hello":".hello_selector"
},
render:function(){
  //this.hello is BackboneMixin(Backbone.View) instance
  this.hello.show(CustomBackboneView); 
  //now instance of CustomBackboneVIew is subview of this.hello view
}
```
Also regions can use for point to point view bindings

```js
regions:{
  hello:{
    el:".hello_selector",
    view: (HelloView = MixinBackbone(Backbone.View).extend({
    }))
  },
  render:function(){
    this.hello.$el === this.$el.find(".hello_selector");
  }
}
```

#### show(view,options)
Type `Function`

#### close(view)
Type `Function`

### setNeedRerenderView(view)
Type `Function`

#### view
Type: `Backbone.View`
Set flag to re-render (call render function after re-open view)

#### setNeedRerender 
Type `Function`
Alias setNeedRerenderView(this)

#### showViewAnimation(view)
Type `Function`

#### showAnimation
Type `Function`
Alias showViewAnimation(this)

#### closeViewAnimation(view)
Type `Function`

#### closeAnimation
Type `Function`
Alias closeViewAnimation(this)

#### getViewDI(ViewParams, options)
Type `Function`



#Run tests
```bash
npm install
bower install
grunt
```

