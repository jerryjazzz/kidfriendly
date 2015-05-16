'use strict'
class DetailsCtrl
  constructor:($scope, place, @placesService, analyticsService, $window, $document)->
    console.log 'place', place
    @_calculateScores(place)
    place.photos = ['img/no-image.jpg'] unless place.photos?
    analyticsService.trackEvent("Details", "View", place.name, place.rating)
    $scope.ratingStyle = (rating) ->
      "rating-bad": rating < 60
      "rating-average": rating >= 60 and rating < 80
      "rating-good": rating >= 80

    $scope.data = {}
    $scope.data.place = place
    $scope.data.mapVisible = false
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

    $scope.navigate = ->
      launchnavigator.navigate [place.lat, place.long], null, ->
        analyticsService.trackEvent("Details", "directions")

  _calculateScores: (place) ->
    return unless place.reviews?
    for review in place.reviews
      @placesService.calculateScore(review)

DetailsCtrl.$inject = ['$scope', 'place', 'placesService', 'analyticsService', '$window', '$document']
angular.module('Mobile').controller 'DetailsCtrl', DetailsCtrl