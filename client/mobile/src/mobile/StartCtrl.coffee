'use strict'
class StartCtrl
  constructor: ($scope, position) ->
    $scope.hasPosition = position?.coords?.latitude?

StartCtrl.$inject = ['$scope', 'position']
angular.module('Mobile').controller 'StartCtrl', StartCtrl