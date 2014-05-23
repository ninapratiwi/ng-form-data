/*global angular:false*/
let angular = angular
  angular.module 'tc-ng-boilerplate' <[]>
  .value 'dummy' (value) ->
    if value
      true
    else
      false
