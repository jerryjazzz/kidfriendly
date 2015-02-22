'use strict'
class SearchCtrl
  constructor:($scope, $state, placesService, position, $stateParams)->
    placesService.search($stateParams.keyword, position).then (results) => $scope.results = results

SearchCtrl.$inject = ['$scope', '$state', 'placesService', 'position', '$stateParams']
angular.module('Mobile').controller 'SearchCtrl', SearchCtrl