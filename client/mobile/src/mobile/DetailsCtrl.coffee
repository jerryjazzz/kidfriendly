'use strict'
class DetailsCtrl
  constructor:($scope, @$stateParams, placesService)->
    $scope.place = placesService.getPlace($stateParams.placeId)


DetailsCtrl.$inject = ['$scope', '$stateParams', 'placesService']
angular.module('Mobile').controller 'DetailsCtrl', DetailsCtrl
