'use strict'
class SearchCtrl
  constructor:($scope, $state, $stateParams, results, userService, analyticsService, @$ionicListDelegate, @$timeout, @placesService)->
    analyticsService.trackEvent("Results", 'display', $stateParams.keyword, results.length)
    $scope.$watch userService.getUser().then (user) => $scope.user = user
    $scope.results = results
    images = [
      "img/place1-thumb.jpg"
      "img/place2-thumb.jpg"
      "img/place3-thumb.jpg"
      "img/place4-thumb.jpg"
      "img/place5-thumb.jpg"
      "img/place6-thumb.jpg"
    ]
    for result in results
      num = Math.floor(Math.random() * 6)
      url = images[num]
      console.log num, url
      result.url = url

    $scope.noResults = results.length == 0
    $scope.goToDetails = (placeId, vote, index) ->
      analyticsService.trackEvent("Results", 'select', "", index+1)
      $state.go 'details', {placeId:placeId, vote:vote}

    $scope.up = ($event, place) =>
      voteValue = 1
      if place.me?.vote != 1
        analyticsService.trackEvent "Results", "upvote"
        place.downvote_count-- if place.me.vote == -1
        place.me =
          vote: voteValue
        place.upvote_count++
      else
        analyticsService.trackEvent "Results", "upvote-deselect"
        voteValue = 0
        place.me.vote = voteValue
        place.upvote_count--
      @handleThumbEvent($event, place, voteValue)

    $scope.down = ($event, place) =>
      voteValue =- 1
      if place.me?.vote != -1
        analyticsService.trackEvent "Results", "downvote"
        place.upvote_count-- if place.me.vote == 1
        place.me =
          vote: voteValue
        place.downvote_count++
      else
        analyticsService.trackEvent "Results", "downvote-deselect"
        voteValue = 0
        place.downvote_count--
        place.me.vote = voteValue
      @handleThumbEvent($event, place, voteValue)


    $scope.getThumbClass  = (voteValue, voteDirection) ->
      if voteDirection == 'down' and voteValue == -1
        return {'thumbs-down':true}
      if voteDirection == 'up' and voteValue == 1
        return {'thumbs-up':true}
      return {'thumbs-unchecked':true}

    $scope.getScore = (place) ->
      score = place.upvote_count - place.downvote_count
      return "-" if score == 0
      score

  handleThumbEvent: (event, place, vote)->
    event.stopPropagation()
    @placesService.vote(place.place_id, vote)
    @$timeout.cancel(@timer) if @timer
    @timer = @$timeout =>
      @$ionicListDelegate.closeOptionButtons()
    , 300

SearchCtrl.$inject = '$scope $state $stateParams results userService analyticsService $ionicListDelegate $timeout placesService'.split(' ')
angular.module('Mobile').controller 'SearchCtrl', SearchCtrl