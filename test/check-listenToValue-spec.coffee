describe "MixinBackbone::listenToValue",->
  beforeEach ->
    TestView = MixinBackbone(Backbone.View).extend
      initialize:->
        @model = new (Backbone.Model.extend {
          defaults:
            value:19
        })
    @view = new TestView    
    flag = false
    @results = []
    runs =>
      @view.listenToValue @view.model, 'value', (model,value)=>
        @results.push {
          'size arguments': 3 is _.size(arguments)
          'model not null': model isnt null
          'value equals': value is model.get('value')
        }      
        flag = true

    waitsFor (-> flag),"wait listenToValue",10 

  afterEach ->
    @view.remove()

  it "check listenToValue",(done)->    
    expect(1).toBe _.size(@results)
    res = @results[0]
    expect(true).toBe res['size arguments']
    expect(true).toBe res['model not null']
    expect(true).toBe res['value equals']

  it "check listenToValue with change model",(done)->
    @view.model.set {value:9}
    expect(2).toBe _.size(@results)
    res = @results[0]
    expect(true).toBe res['size arguments']
    expect(true).toBe res['model not null']
    expect(true).toBe res['value equals']

    res = @results[1]
    expect(true).toBe res['size arguments']
    expect(true).toBe res['model not null']
    expect(true).toBe res['value equals']