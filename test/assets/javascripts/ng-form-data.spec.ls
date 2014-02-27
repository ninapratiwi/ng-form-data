(...) <-! describe 'module ng-form-data'
it 'should be defined' !(...) ->
  expect ng-form-data .toBeDefined!

it 'should return true value' !(...) ->
  const value = ng-form-data {}
  expect value .toEqual true

it 'should return false value' !(...) ->
  const value = ng-form-data ''
  expect value .toEqual false