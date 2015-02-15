'use strict'
class DetailsCtrl
  constructor:($scope, place, $window)->
    place.photos = ['img/no-image.jpg'] unless place.photos?
    $scope.data = {}
    $scope.data.place = place
    $scope.data.mapVisible = false
    $scope.data.mapStyle =
      "button-dark":true
      "button-selected":false
    console.log 'place', place
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

DetailsCtrl.$inject = ['$scope', 'place', '$window']
angular.module('Mobile').controller 'DetailsCtrl', DetailsCtrl
