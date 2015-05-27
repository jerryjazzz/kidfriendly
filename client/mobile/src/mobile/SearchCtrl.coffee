'use strict'
class SearchCtrl
  constructor:($scope, $state, $stateParams, results, userService, analyticsService, @$ionicListDelegate, @$timeout, @placesService)->
    analyticsService.trackEvent("Results", 'display', $stateParams.keyword, results.length)
    $scope.$watch userService.getUser().then (user) => $scope.user = user
    $scope.results = results

    $scope.noResults = results.length == 0
    $scope.goToDetails = (placeId, index) ->
      analyticsService.trackEvent("Results", 'select', "", index+1)
      $state.go 'details', {placeId:placeId}

    $scope.up = ($event, place) =>
      voteValue = 1
      if !place.me?.vote != 1
        place.me =
          vote: voteValue
      else
        voteValue = 0
        place.me.vote = voteValue
      @handleThumbEvent($event, place, voteValue)

    $scope.down = ($event, place) =>
      voteValue =- 1
      if !place.me?.vote != -1
        place.me =
          vote: voteValue
      else
        voteValue = 0
        place.me.vote = voteValue
      @handleThumbEvent($event, place, voteValue)

    $scope.getThumbClass  = (voteValue, voteDirection) ->
      if voteDirection == 'down' and voteValue == -1
        return {'thumbs-down':true}
      if voteDirection == 'up' and voteValue == 1
        return {'thumbs-up':true}
      return {'thumbs-unchecked':true}


  handleThumbEvent: (event, place, vote)->
    event.stopPropagation()
    @placesService.vote(place.place_id, vote)
    @$timeout.cancel(@timer) if @timer
    @timer = @$timeout =>
      @$ionicListDelegate.closeOptionButtons()
    , 300

SearchCtrl.$inject = '$scope $state $stateParams results userService analyticsService $ionicListDelegate $timeout placesService'.split(' ')
angular.module('Mobile').controller 'SearchCtrl', SearchCtrl