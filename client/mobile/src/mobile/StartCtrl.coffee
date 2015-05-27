'use strict'
class StartCtrl
  constructor: ($scope, position, userService, $window, $cordovaAppVersion) ->
    $scope.data = {}
    $scope.data.hasPosition = position?.coords?.latitude?
    $scope.data.userData = {}
    $scope.data.user = userService.user
    $cordovaAppVersion.getAppVersion().then (version) ->
      $scope.version = version

    $scope.logout = ->
      userService.logout()

StartCtrl.$inject = ['$scope', 'position', 'userService', '$window', '$cordovaAppVersion']
angular.module('Mobile').controller 'StartCtrl', StartCtrl