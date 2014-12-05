'use strict'
class SearchCtrl
  constructor:($scope, $state, placesService, locationService)->
    locationService.getPosition().then (position) =>
      console.log 'pos', position.coords.longitude
      console.log 'pos', position.coords.latitude

    $scope.performSearch = (keyword)=>
      placesService.search(keyword).then -> $state.go('results')


SearchCtrl.$inject = ['$scope', '$state', 'placesService', 'locationService']
angular.module('Mobile').controller 'SearchCtrl', SearchCtrl