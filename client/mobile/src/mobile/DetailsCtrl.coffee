'use strict'
class DetailsCtrl
  constructor:($scope, place)->
    $scope.data = {}
    $scope.data.place = place

DetailsCtrl.$inject = ['$scope', 'place']
angular.module('Mobile').controller 'DetailsCtrl', DetailsCtrl
