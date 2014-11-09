'use strict'
class ReviewCtrl
  constructor:($scope, placesService, $stateParams)->
    console.log 'review', $stateParams.placeId
    $scope.place = placesService.getPlace($stateParams.placeId)

ReviewCtrl.$inject = ['$scope', 'placesService', '$stateParams']

angular.module('Mobile').controller('ReviewCtrl', ReviewCtrl)