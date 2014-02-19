describe "Check MixinBackbone prototype", ->
  beforeEach ->
    @TestView = MixinBackbone(Backbone.View)
  it "check TestView::_diViewsKeys",->
    expect(!!@TestView::_diViewsKeys).toBeTruthy()
  it "check TestView::_diViewsValues",->
    expect(!!@TestView::_diViewsValues).toBeTruthy()
  it "check TestView::show",->
    expect(!!@TestView::show).toBeTruthy()
  it "check TestView::close",->
    expect(!!@TestView::close).toBeTruthy()
  it "check TestView::showAnimation",->
    expect(!!@TestView::showAnimation).toBeTruthy()
  it "check TestView::closeAnimation",->
    expect(!!@TestView::closeAnimation).toBeTruthy()
  it "check TestView::showViewAnimation",->
    expect(!!@TestView::showViewAnimation).toBeTruthy()
  it "check TestView::closeViewAnimation",->
    expect(!!@TestView::closeViewAnimation).toBeTruthy()
  it "check TestView::getViewDI",->
    expect(!!@TestView::getViewDI).toBeTruthy()
  it "check TestView::reloadTemplate",->
    expect(!!@TestView::reloadTemplate).toBeTruthy()
  it "check TestView::unbindRegions",->
    expect(!!@TestView::unbindRegions).toBeTruthy()
  it "check TestView::bindRegions",->
    expect(!!@TestView::bindRegions).toBeTruthy()
  it "check TestView::bindUIElements",->
    expect(!!@TestView::bindUIElements).toBeTruthy()
  it "check TestView::bindUIEpoxy",->
    expect(!!@TestView::bindUIEpoxy).toBeTruthy()
