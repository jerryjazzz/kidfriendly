'use strict'
class SearchCtrl
  constructor:($scope, $state, placesService, @locationService, $stateParams)->
    if @locationService.cachedPosition?
      placesService.search($stateParams.keyword, @locationService.cachedPosition).then (results) => $scope.searchResults = results
    else
      @locationService.fetchPosition().then (position) =>
        placesService.search($stateParams.keyword, position).then (results) => $scope.searchResults = results

SearchCtrl.$inject = ['$scope', '$state', 'placesService', 'locationService', '$stateParams']
angular.module('Mobile').controller 'SearchCtrl', SearchCtrl