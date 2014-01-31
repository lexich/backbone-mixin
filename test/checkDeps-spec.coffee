describe "Check dependencies", ->
  it "check lodash/underscore", ->
    expect(!!_).toBeTruthy()
  it "check Backbone", ->
    expect(!!Backbone).toBeTruthy()
  it "check Backbone.$", ->
    expect(!!Backbone.$).toBeTruthy()
  it "check MixinBackbone", ->
    expect(!!MixinBackbone).toBeTruthy()