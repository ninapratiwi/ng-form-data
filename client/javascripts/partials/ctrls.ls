angular.module 'demo'
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
