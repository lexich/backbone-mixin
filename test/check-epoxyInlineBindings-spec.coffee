describe "Epoxy inline bindings",->
  beforeEach ->
    $('body').html """
        <div id='view'>
          <h1 data-bind="text: title"></h1>
        </div>
        """

  afterEach ->
    $('#view').remove()

  it "check inline binding works", ->
    TestView = MixinBackbone(Backbone.Epoxy.View).extend
      el: '#view'
      model: new (Backbone.Model.extend
        defaults:
          title: "Title"
      )
    view = new TestView
    expect(view.$('h1').text()).toEqual "Title"
