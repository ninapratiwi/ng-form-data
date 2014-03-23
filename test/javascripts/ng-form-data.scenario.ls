(...) <-! describe 'module ng-form-data'
const ptor      = protractor.getInstance!

it 'should work' !(...) ->
  ptor.get '/'

  expect element(by.css '.navbar-brand').getText! .toBe 'ng-form-data'
