'use strict'
class DetailsCtrl
  constructor:($scope, @$stateParams, placesService)->
    $scope.data = {}
    placesService.getPlaceDetail($stateParams.placeId).then (place) =>
      $scope.data.place = place


DetailsCtrl.$inject = ['$scope', '$stateParams', 'placesService']
angular.module('Mobile').controller 'DetailsCtrl', DetailsCtrl
