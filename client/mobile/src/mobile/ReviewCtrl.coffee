'use strict'
class ReviewCtrl
  constructor:($scope, placesService, $stateParams)->
    $scope.place = placesService.getPlace($stateParams.placeId)
    $scope.submit = () -> console.log 'clicky'

ReviewCtrl.$inject = ['$scope', 'placesService', '$stateParams']

angular.module('Mobile').controller('ReviewCtrl', ReviewCtrl)