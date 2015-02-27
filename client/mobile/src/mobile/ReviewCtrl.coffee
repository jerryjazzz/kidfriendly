'use strict'
class ReviewCtrl
  constructor:($scope, placesService, $stateParams, user, $ionicModal)->
    $scope.data = {}
    $scope.data.review =
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
      $scope.modal.hide()

    $scope.$on '$destroy', ->
      $scope.modal.remove()

    $scope.submit = () ->
      name = "#{user.current.first_name} #{user.current.last_name?.substring(0, 1)}"
      $scope.data.review.name = name
      placesService.submitReview(user.current.user_id, $stateParams.placeId, $scope.data.review)
      $scope.modal.show()
#      .then ->


#      .error ->


ReviewCtrl.$inject = ['$scope', 'placesService', '$stateParams', 'user', '$ionicModal']

angular.module('Mobile').controller('ReviewCtrl', ReviewCtrl)