const ImgurInterceptor = 'ImgurInterceptor'

angular.module 'demo' <[
  ui.bootstrap
  ng-form-data
]>
.config <[
        $httpProvider
]> ++ !($httpProvider) ->

  $httpProvider.defaults.headers.common <<< {
    'Authorization': 'Client-ID 7f621a4d42a20a7'
  }

  $httpProvider.interceptors.push ImgurInterceptor

.factory ImgurInterceptor, <[
       $q
]> ++ ($q) ->

  response: (response) ->
    const {data, success, status} = response.data
    response.data = data
    response = $q.reject response unless success
    response
