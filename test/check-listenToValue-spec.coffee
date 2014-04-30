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

  it "check old syntax",->
    checkSuccess = 0
    flag = false
    runs =>      
      @view.listenToValue @view.model, "change:value",(model, value)=>
        checkSuccess = value
        flag = true

    waitsFor (-> 
      if flag
        expect(19).toBe checkSuccess
      flag
    ),"wait listenToValue",10
    


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

  it "check stopListenValue",->
    checkValue = 0
    expect(0).toBe checkValue
    @view.listenToValue @view.model, "value",(model,value)->
      checkValue = value    
    @view.model.set {value:50}
    expect(50).toBe checkValue
    @view.remove()
    @view.model.set {value:10}
    expect(50).toBe checkValue