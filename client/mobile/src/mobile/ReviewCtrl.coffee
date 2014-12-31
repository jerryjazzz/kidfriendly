'use strict'
class ReviewCtrl
  constructor:($scope, placesService, $stateParams, user, $ionicModal)->
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

    $scope.submit = (review) ->
      placesService.submitReview(user.current.user_id, $stateParams.placeId, review)
      $scope.modal.show()
#      .then ->


#      .error ->


ReviewCtrl.$inject = ['$scope', 'placesService', '$stateParams', 'user', '$ionicModal']

angular.module('Mobile').controller('ReviewCtrl', ReviewCtrl)