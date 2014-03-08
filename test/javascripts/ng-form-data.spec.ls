const FileWithFormDataInterceptor = 'FileWithFormDataInterceptor'

(...) <-! describe 'module ng-form-data'
beforeEach module 'ng-form-data'

interceptor = void

beforeEach !($inject) ->
  interceptor := $inject.get FileWithFormDataInterceptor

it 'should not transform $http config with pure json' !(...) ->
  const json = do
    name: 'ng-form-data'
    keywords: <[
      Angular
      directive
      ng-model
      input
      FormData
      file
      image
      upload
    ]>

  const config = interceptor.request data: json, method: 'POST'

  expect config.data .toEqual json