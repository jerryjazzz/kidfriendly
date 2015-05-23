'use strict'
class SearchCtrl
  constructor:($scope, $state, $stateParams, results, analyticsService, @$ionicListDelegate, @$timeout)->
    analyticsService.trackEvent("Results", 'display', $stateParams.keyword, results.length)

    $scope.results = results
    $scope.noResults = results.length == 0
    $scope.goToDetails = (placeId, index) ->
      analyticsService.trackEvent("Results", 'select', "", index+1)
      $state.go 'details', {placeId:placeId}

    $scope.up = ($event, item) =>
      item.thumbsUp = yes
      item.thumbsDown = no
      $event.stopPropagation()
      @handleThumbEvent()

    $scope.down = ($event, item) =>
      item.thumbsDown = yes
      item.thumbsUp = no
      $event.stopPropagation()
      @handleThumbEvent()

  handleThumbEvent:->
    @$timeout.cancel(@timer) if @timer
    @timer = @$timeout =>
      @$ionicListDelegate.closeOptionButtons()
    , 300

SearchCtrl.$inject = ['$scope', '$state', '$stateParams', 'results', 'analyticsService', '$ionicListDelegate', '$timeout']
angular.module('Mobile').controller 'SearchCtrl', SearchCtrl