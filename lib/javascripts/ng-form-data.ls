/*global angular:false*/
let angular = angular, element = angular.element, forEach = angular.forEach, identity = angular.identity, isObject = angular.isObject, lowercase = angular.lowercase, FileWithFormDataInterceptor = 'FileWithFormDataInterceptor', toString$ = {}.toString

  function typeOf (object)
    toString$.call object .slice 8, -1

  function encodeKey (keyPrefix, key)
    key = "[#key]" if keyPrefix.length
    "#keyPrefix#key"

  const httpBackendWithIframeTransport = <[
         $delegate  $document
  ]> ++ ($delegate, $document) ->
    #
    # https://github.com/angular/angular.js/blob/master/src/ng/httpBackend.js#L43
    #
    !(method, url, post, callback, headers, timeout, withCredentials, responseType) ->
      const matcher = lowercase method .match /^iframe:(\S+)/i
      return $delegate ...& unless matcher

      const name = "iframe-#{ Date.now! }"
      const $form = element '<form></form>' .addClass 'ng-hide' .attr do
        enctype: 'multipart/form-data'
        method: matcher.1
        action: url
        target: name
      forEach post, !-> $form.append it

      const $iframe = element '<iframe></iframe>' .addClass 'ng-hide' .attr do
        src: 'javascript:false;'
        name: name
        id: name

      # The first load event gets fired after the iframe has been injected
      # into the DOM, and is used to prepare the actual submission.
      $iframe.one 'load' !->

        # The second load event gets fired when the response to the form
        # submission is received. The implementation detects whether the
        # actual payload is embedded in a `<textarea>` element, and
        # prepares the required conversions to be made in that case.
        $iframe.one 'load' !->
          const doc = if @contentWindow then that.document else
            if @contentDocument then that else @document
          const root = if doc.documentElement then doc.documentElement else doc.body
          const value = if root then root.textContent || root.innerText else null

          console.log value


          # textarea = root.getElementsByTagName("textarea")[0],
          # type = textarea && textarea.getAttribute("data-type") || null,
          # status = textarea && textarea.getAttribute("data-status") || 200,
          # statusText = textarea && textarea.getAttribute("data-statusText") || "OK",
          # content = {
          #   html: root.innerHTML,
          #   text: type ?
          #     textarea.value :
          #     root ? (root.textContent || root.innerText) : null
          # };

          # cleanUp();
          # completeCallback(
          #   status,
          #   statusText,
          #   content,
          #   type ? ("Content-Type: " + type) : null
          # );

        # Now that the load handler has been set up, submit the form.
        $form.0.submit!
      # end of first load event
      $document
        .find 'body'
        .append $form
        .append $iframe

  function IFrameTransportEncoder (config)
    @_i  = []
    @enc config.data, ''

    config.method = "iframe:#{ config.method }"
    config.data = @_i
    config.transformRequest = identity
    config

  IFrameTransportEncoder::enc = !(data, keyPrefix) ->
    forEach data, !(value, key) ->
      key = encodeKey keyPrefix, key
      const attr = do
        type: 'hidden'
        name: key

      switch typeOf value
      | 'Function', 'Blob' => return
      | 'FileList', 'File' => return @_i.push value.$$inputElClone
      | _ => return @enc value, key if isObject value

      element '<input>' .attr attr .val value |> @_i.push
    , @


  function FormDataEncoder (FormData, config)
    const {data} = config
    if 'FormData' is typeOf data
      @_d = data
      @_v = true
    else if isObject data
      @_d = new FormData
      @_v = false
      @enc data, ''
    #
    if @_v
      delete! config.headers['Content-Type']

      config.data = @_d
      config.transformRequest = identity
    config

  FormDataEncoder::enc = !(data, keyPrefix) ->
    forEach data, !(value, key) ->
      key = encodeKey keyPrefix, key
      
      switch typeOf value
      | 'Function' => return
      | 'File', 'Blob' => @_v = true
      | /*'FileList',*/ _ => return @enc value, key if isObject value
      #
      # https://developer.mozilla.org/en-US/docs/Web/API/FormData
      #
      @_d.append key, value
    , @


  angular.module 'ng-form-data' <[
  ]>
  .directive 'input' ->

    !function postLinkFn ($scope, $element, $attrs, ctrl)
      const ngModelCtrl = ctrl or {$setViewValue: angular.noop}
      ngModelCtrl.$open = !-> $element.0.click!

      <-! $element.on 'change'
      const {files} = @
      const viewValue = if $attrs.multiple then files else files.0
      viewValue.$$inputElClone = @clone!

      <-! $scope.$apply
      ngModelCtrl.$setViewValue viewValue
    #
    restrict: 'E'
    require: '?ngModel'
    compile: (tElement, tAttrs) ->
      postLinkFn if 'file' is tAttrs.type

  .config <[
          $httpProvider  $provide
  ]> ++ !($httpProvider, $provide) ->

    $httpProvider.interceptors.push FileWithFormDataInterceptor

    $provide.decorator '$httpBackend' httpBackendWithIframeTransport

  .factory FileWithFormDataInterceptor, <[
         $window
  ]> ++ ($window) ->

    const {FormData} = $window

    request: ->
      if lowercase it.method .match /^(get|head)$/i
        it
      # else if FormData
      #   new FormDataEncoder FormData, it
      else
        new IFrameTransportEncoder it
