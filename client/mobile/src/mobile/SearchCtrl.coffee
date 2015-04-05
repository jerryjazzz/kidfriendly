'use strict'
class SearchCtrl
  constructor:($scope, $state, $stateParams, results, analyticsService)->
    analyticsService.trackEvent("Results", 'display', $stateParams.keyword, results.length)
    $scope.results = results
    $scope.goToDetails = (placeId, index) ->
      analyticsService.trackEvent("Results", 'select', "", index+1)
      $state.go 'details', {placeId:placeId}

SearchCtrl.$inject = ['$scope', '$state', '$stateParams', 'results', 'analyticsService']
angular.module('Mobile').controller 'SearchCtrl', SearchCtrl