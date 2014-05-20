/*global angular:false*/
let angular = angular, element = angular.element, forEach = angular.forEach, identity = angular.identity, isObject = angular.isObject, lowercase = angular.lowercase, FileWithFormDataInterceptor = 'FileWithFormDataInterceptor', toString$ = {}.toString
# TODO
  function typeOf (object)
    toString$.call object .slice 8, -1

  function encodeKey (keyPrefix, key)
    key = "[#key]" if keyPrefix.length
    "#keyPrefix#key"

  const httpBackendWithIframeTransport = <[
         $delegate  $browser  $document  $rootScope
  ]> ++ ($delegate, $browser, $document, $rootScope) ->
    const $browserDefer = $browser.defer

    #
    # https://github.com/angular/angular.js/blob/master/src/ng/httpBackend.js#L43
    #
    !(method, url, post, callback, headers, timeout, withCredentials, responseType) ->
      const matcher = lowercase method .match /^iframe:(\S+)/i
      return $delegate ...& unless matcher
      $browser.$$incOutstandingRequestCount!

      const name = "iframe-#{ Date.now! }"
      const $form = element '<form class="ng-hide"></form>' .attr do
        enctype: 'multipart/form-data'
        method: matcher.1
        action: url
        target: name
      forEach post, !-> $form.append it

      const $iframe = element '<iframe class="ng-hide"></iframe>' .attr do
        src: 'javascript:false;'
        name: name
        id: name

      # The first load event gets fired after the iframe has been injected
      # into the DOM, and is used to prepare the actual submission.
      .one 'load' !->
        # The second load event gets fired when the response to the form
        # submission is received. The implementation detects whether the
        # actual payload is embedded in a `<textarea>` element, and
        # prepares the required conversions to be made in that case.
        $iframe.one 'load' !->
          const doc = if @contentWindow then that.document else
            if @contentDocument then that else @document
          const root = if doc.documentElement then doc.documentElement else doc.body
          const response = if root then root.textContent || root.innerText else null

          completeRequest callback, 200, response, '', 'OK'
        # Now that the load handler has been set up, submit the form.
        $form.0.submit!
      # end of first load event
      $document
        .find 'body'
        .append $form
        .append $iframe

      if timeout > 0
        const timeoutId = $browserDefer timeoutRequest, timeout
      else if timeout and timeout.then
        timeout.then timeoutRequest


      !function timeoutRequest
        $form.remove!
        $iframe.remove!
        # status = ABORTED;
        # jsonpDone && jsonpDone();
        # xhr && xhr.abort();

      !function completeRequest(callback, status, response, headersString, statusText)
        # cancel timeout and subsequent timeout promise resolution
        timeoutId and $browserDefer.cancel timeoutId

        callback status, response, headersString, statusText

        $browser.$$completeOutstandingRequest timeoutRequest


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
      if value.$$inputEl
        that.replaceWith that.clone!
      else
        switch typeOf value
        | 'Function', 'Blob', 'FileList', 'File' => return# ignore
        return @enc value, key if isObject value# encode nested object
        that = element '<input type="hidden">' .val value

      @_i.push that.attr 'name' key
    , @


  function FormDataEncoder (config, FormData)
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
  .provider FileWithFormDataInterceptor, !->

    @$get = <[
           $window
    ]> ++ ($window) ~>
      const {FormData} = $window

      @$isFormDataSupported = !!FormData

      const $useFormData = if '$useFormData' of @ then @$useFormData
      else @$useFormData = @$isFormDataSupported

      const Encoder = if $useFormData then FormDataEncoder
      else IFrameTransportEncoder

      $useFormData: $useFormData
      request: ->
        if lowercase it.method .match /^(get|head)$/i then it
        else new Encoder it, FormData

  .directive 'input' [
        FileWithFormDataInterceptor
  ] ++ (FileWithFormDataInterceptor) ->

    const {$useFormData} = FileWithFormDataInterceptor
   
    !function postLinkFn ($scope, $element, $attrs, ctrl)
      const ngModelCtrl = ctrl or {$setViewValue: angular.noop}
      ngModelCtrl.$open = !-> $element.0.click!

      <-! $element.on 'change'
      const {files} = @
      const viewValue = if $useFormData
        if $attrs.multiple then files else files.0
      else
        $$inputEl: $element# cache the input

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
