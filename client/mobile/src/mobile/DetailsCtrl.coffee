'use strict'
class DetailsCtrl
  constructor:($scope, place, userService, @placesService, analyticsService, $window, $stateParams, $ionicModal, $rootScope)->
    @_calculateScores(place)
    place.me = {}
    place.me.vote = parseInt($stateParams.vote, 10)

    $ionicModal.fromTemplateUrl 'templates/login-modal.html',
      scope: $scope
      animation: 'slide-in-up'
    .then (modal) ->
      $scope.modal = modal

    place.photos = [
      "img/place1.jpg"
      "img/place2.jpg"
      "img/place3.jpg"
      "img/place4.png"
      "img/place5.jpg"
      "img/place6.jpg"
    ]
    analyticsService.trackEvent("Details", "View", place.name, place.rating)
    $scope.ratingStyle = (rating) ->
      "rating-bad": rating < 60
      "rating-average": rating >= 60 and rating < 80
      "rating-good": rating >= 80

    $scope.data = {}
    $scope.data.place = place
    $scope.data.mapVisible = yes
    $scope.data.mapStyle =
      "button-dark":true
      "button-selected":false
    $scope.map =
      center:
        latitude: place.lat
        longitude: place.long
      options:
        disableDefaultUI: true
        scrollwheel: false
        navigationControl: false
        mapTypeControl: false
        scaleControl: false
        disableDoubleClickZoom: false
        draggable: false

    $scope.toggleMap = ->
      $scope.data.mapVisible = !$scope.data.mapVisible
      $scope.data.mapStyle["button-dark"]= !$scope.data.mapVisible
      $scope.data.mapStyle["button-selected"] = $scope.data.mapVisible
      mapVisible = if $scope.data.mapVisible then "show" else "hide"
      analyticsService.trackEvent("Details", "Toggle Map", mapVisible)

    $scope.makeCall = (phoneNumber) ->
      analyticsService.trackEvent("Details", "Make Call")
      phoneNumber = phoneNumber.replace(/\W/g, "")
      $window.open("tel:#{phoneNumber}", '_system')

    $scope.up = ($event) =>
      userService.getUser().then (user) =>
        if user.isAuthenticated()
          voteValue = 1
          if place.me.vote != 1
            analyticsService.trackEvent "Details", "upvote"
            place.downvote_count-- if place.me.vote == -1
            place.me =
              vote: voteValue
            place.upvote_count++
          else
            analyticsService.trackEvent "Details", "upvote-deselect"
            voteValue = 0
            place.me.vote = voteValue
            place.upvote_count--
          @handleThumbEvent($event, place, voteValue)
        else
          $scope.login('up')

    $scope.down = ($event) =>
      userService.getUser().then (user) =>
        if user.isAuthenticated()
          voteValue =- 1
          if place.me.vote != -1
            analyticsService.trackEvent "Details", "downvote"
            place.upvote_count-- if place.me.vote == 1
            place.me =
              vote: voteValue
            place.downvote_count++
          else
            analyticsService.trackEvent "Details", "downvote-deselect"
            voteValue = 0
            place.downvote_count--
            place.me.vote = voteValue
          @handleThumbEvent($event, place, voteValue)
        else
          $scope.login('down')

    $scope.login = (meCallback)->
      $rootScope.$on '$authenticationSuccess', (user)->
        console.log 'close modal'
        $scope.closeModal()
        $scope[meCallback]()
      $scope.modal.show()

    $scope.getThumbClass  = (voteValue, voteDirection) ->
      console.log 'in here'
      if voteDirection == 'down' and voteValue == -1
        console.log 'thumbs down'
        return {'button-assertive':true}
      if voteDirection == 'up' and voteValue == 1
        console.log 'thumbs up'
        return {'button-balanced':true}
      return {'button-dark':true}

    $scope.navigate = ->
      launchnavigator.navigate [place.lat, place.long], null, ->
        analyticsService.trackEvent("Details", "directions")

    $scope.closeModal = ->
      $scope.modal.hide()

    $scope.$on '$destroy', ->
      $scope.modal.remove()

    $scope.openWebsite = ->
      $window.open(place.website, '_system');

  _calculateScores: (place) ->
    return unless place.reviews?
    for review in place.reviews
      @placesService.calculateScore(review)

  handleThumbEvent: (event, place, vote)->
    event?.stopPropagation()
    @placesService.vote(place.place_id, vote)

DetailsCtrl.$inject = '$scope place userService placesService analyticsService $window $stateParams $ionicModal $rootScope'.split(' ')
angular.module('Mobile').controller 'DetailsCtrl', DetailsCtrl