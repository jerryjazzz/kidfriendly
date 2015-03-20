'use strict'
positionResolver = (locationService)-> return locationService.fetchPosition()

positionResolver.$inject = ['locationService']

placeResolver = (placesService, $stateParams) ->
  placesService.getPlaceDetail($stateParams.placeId)

searchResolver = (locationService, placesService, $stateParams) ->
  locationService.fetchPosition().then (position) ->
    #safari acts funny if i just pass position to search() need to call accessors
    coords =
      latitude: position.coords.latitude
      longitude: position.coords.longitude
    placesService.search($stateParams.keyword, coords)


placeResolver.$inject = ['placesService', '$stateParams']

resolvers =
  position: positionResolver
  place: placeResolver
  results: searchResolver

angular.module('Mobile').constant 'resolvers', resolvers