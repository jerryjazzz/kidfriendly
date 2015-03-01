'use strict'
class DetailsCtrl
  constructor:($scope, place, $window)->
    @_calculateScores(place)
    place.photos = ['img/no-image.jpg'] unless place.photos?
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

  _calculateScores: (place) ->
    for review in place.reviews
      review.score = review.score = review.body.kidsMenu * 6 +
        review.body.healthOptions * 6 +
        review.body.accommodations * 4 +
        review.body.service * 4

DetailsCtrl.$inject = ['$scope', 'place', '$window']
angular.module('Mobile').controller 'DetailsCtrl', DetailsCtrl
