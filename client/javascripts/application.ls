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

.controller 'ImgurCtrl' class

  upload: !->
    const {newImg} = @$scope

    @$http.post 'https://api.imgur.com/3/image' newImg
    .then ({data}) ~>
      /*!
       * imgur bug, it won't return title and description
       * need to get it again
       */
      @$http.get "https://api.imgur.com/3/image/#{ data.id }"
      .then (response) ->
        angular.extend data, response.data
        {data}
    .then ({data}) ~>
      @$scope <<< {
        newImg: void
        image: data
      }

  delete: !->
    const {image} = @$scope

    @$http.delete "https://api.imgur.com/3/image/#{ image.deletehash }"
    .then !~>
      @$scope.image = void

  @$inject = <[
     $scope   $http ]>
  !(@$scope, @$http) ->
