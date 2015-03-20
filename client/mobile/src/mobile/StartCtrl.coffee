'use strict'
class StartCtrl
  constructor: ($scope, position) ->
    $scope.hasPosition = position?.coords?.latitude?
    $scope.userData = {}

    $scope.searchPostal = ->
      console.log 'hello??', $scope.userData.postalCode

StartCtrl.$inject = ['$scope', 'position']
angular.module('Mobile').controller 'StartCtrl', StartCtrl