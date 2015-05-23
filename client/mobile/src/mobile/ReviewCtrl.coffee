'use strict'
class ReviewCtrl
  constructor:($scope, placesService, $stateParams, $ionicModal, $ionicHistory, analyticsService)->
    $scope.data = {}
    $scope.data.review = {}
    $scope.data.review.body =
      kidsMenu:0
      healthOptions:0
      service: 0
      accommodations:0
      comments:""

    placesService.getPlaceDetail($stateParams.placeId).then (data) => $scope.place = data
    $ionicModal.fromTemplateUrl 'templates/thank-you-modal.html',
      scope: $scope
      animation: 'slide-in-up'
    .then (modal) ->
      $scope.modal = modal

    $scope.closeModal = ->
      $ionicHistory.clearCache()
      $ionicHistory.goBack()
      $scope.modal.hide()

    $scope.$on '$destroy', ->
      $scope.modal.remove()

    $scope.submit = () ->
#      name = "#{user.current.first_name} #{user.current.last_name?.substring(0, 1)}"
#      $scope.data.review.name = name
      placesService.submitReview($stateParams.placeId, $scope.data.review)
#      analyticsService.trackEvent("Review", "submit", 'new', placesService.calculateScore($scope.data.review))
      $scope.modal.show()

ReviewCtrl.$inject = [
  '$scope'
  'placesService'
  '$stateParams'
  '$ionicModal'
  '$ionicHistory'
  'analyticsService'
]

angular.module('Mobile').controller('ReviewCtrl', ReviewCtrl)