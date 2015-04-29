'use strict'
class StartCtrl
  constructor: ($scope, position, userService, $window) ->
    $scope.data = {}
    $scope.data.hasPosition = position?.coords?.latitude?
    $scope.data.userData = {}
    $scope.data.user = userService.user
    $scope.logout = ->
      userService.logout()

StartCtrl.$inject = ['$scope', 'position', 'userService', '$window']
angular.module('Mobile').controller 'StartCtrl', StartCtrl