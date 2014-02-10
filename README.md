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
#### templateData
Type `Object` or `Function`

#### templateFunc
Type `Function`


#### regions
Type `Object`


### setNeedRerenderView(view)
Type `Function`

#### view
Type: `Backbone.View`
Set flag to re-render (call render function after re-open view)

#### setNeedRerender 
Type `Function`
Alias setNeedRerenderView(this)

#### show(view,options)
Type `Function`

#### close(view)
Type `Function`

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

