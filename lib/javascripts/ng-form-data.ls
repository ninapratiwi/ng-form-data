/*global angular:false*/
const FileWithFormDataInterceptor = 'FileWithFormDataInterceptor'

angular.module 'ng-form-data' <[
]>
.directive 'input' ->

  !function postLinkFn ($scope, $element, $attrs, ctrl)
    const ngModelCtrl = ctrl or {$setViewValue: angular.noop}
    ngModelCtrl.$open = !-> $element.0.click!

    <-! $element.on 'change'
    const {files} = @
    <-! $scope.$apply
    ngModelCtrl.$setViewValue if $attrs.multiple then files else files.0
  #
  restrict: 'E'
  require: '?ngModel'
  compile: (tElement, tAttrs) ->
    return if 'file' isnt tAttrs.type
    postLinkFn

.config <[
        $httpProvider
]> ++ !($httpProvider) ->

  $httpProvider.interceptors.push FileWithFormDataInterceptor     

.factory FileWithFormDataInterceptor, <[
       $window 
]> ++ ($window) ->
  function encodeKey (keyPrefix, key)
    key = "[#key]" if keyPrefix.length
    "#keyPrefix#key"

  RequestTransformer::_e = !(data, keyPrefix) ->
    (value, key) <~! angular.forEach data
    key = encodeKey keyPrefix, key
    
    switch typeof! value
    | 'File', 'Blob' => @_v = true
    | 'Function' => return
    | _ => return @_e value, key if angular.isObject value
    #
    # https://developer.mozilla.org/en-US/docs/Web/API/FormData
    #
    @_d.append key, value    

  function RequestTransformer (config)
    @_d = new $window.FormData
    @_v = false

    @_e config.data, ''
    if @_v
      delete! config.headers['Content-Type']

      config.data = @_d
      config.transformRequest = angular.identity
    config

  request: ->
    return it if 'GET' is angular.uppercase it.method
    return it if 'FormData' is typeof! it
    new RequestTransformer it
