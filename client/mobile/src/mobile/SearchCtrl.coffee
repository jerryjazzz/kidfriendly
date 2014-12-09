'use strict'
class SearchCtrl
  constructor:($scope, $state, placesService, @locationService)->


    $scope.performSearch = (keyword)=>
      @locationService.getPosition(false).then (position) =>
        placesService.search(keyword, position).then ->
          $state.go('results')

SearchCtrl.$inject = ['$scope', '$state', 'placesService', 'locationService']
angular.module('Mobile').controller 'SearchCtrl', SearchCtrl