'use strict'
class ReviewCtrl
  constructor:($scope, placesService, reviewService, $stateParams)->
    $scope.place = placesService.getPlace($stateParams.placeId)

ReviewCtrl.$inject = ['$scope', 'placesService','reviewService', '$stateParams']

angular.module('Mobile').controller('ReviewCtrl', ReviewCtrl)