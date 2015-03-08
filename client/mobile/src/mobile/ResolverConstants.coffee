'use strict'
positionResolver = (locationService)-> return locationService.fetchPosition()

positionResolver.$inject = ['locationService']

placeResolver = (placesService, $stateParams) ->
  placesService.getPlaceDetail($stateParams.placeId)

placeResolver.$inject = ['placesService', '$stateParams']

resolvers =
  position: positionResolver
  place: placeResolver

angular.module('Mobile').constant 'resolvers', resolvers