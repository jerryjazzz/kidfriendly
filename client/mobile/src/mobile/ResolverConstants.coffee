'use strict'
positionResolver = (locationService)-> return locationService.fetchPosition()

positionResolver.$inject = ['locationService']

mapCoords = (position) ->
  #safari acts funny if i just pass position to search() need to call accessors
  coords =
    latitude: position.coords.latitude
    longitude: position.coords.longitude
  coords

placeResolver = (locationService, placesService, $stateParams) ->
  locationService.fetchPosition().then (position) ->
    placesService.getPlaceDetail($stateParams.placeId, mapCoords(position))

searchResolver = (locationService, placesService, $stateParams) ->
  locationService.fetchPosition().then (position) ->
    placesService.search($stateParams.keyword, mapCoords(position))


placeResolver.$inject = ['locationService', 'placesService', '$stateParams']
searchResolver.$inject = ['locationService', 'placesService', '$stateParams']

resolvers =
  position: positionResolver
  place: placeResolver
  results: searchResolver

angular.module('Mobile').constant 'resolvers', resolvers