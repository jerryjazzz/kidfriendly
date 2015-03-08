'use strict'
class SearchCtrl
  constructor:($scope, $state, placesService, position, $stateParams)->
    #safari acts funny if i just pass position to search() need to call accessors
    coords =
      latitude: position.coords.latitude
      longitude: position.coords.longitude
    placesService.search($stateParams.keyword, coords).then (results) => $scope.results = results

SearchCtrl.$inject = ['$scope', '$state', 'placesService', 'position', '$stateParams']
angular.module('Mobile').controller 'SearchCtrl', SearchCtrl