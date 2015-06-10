'use strict'

class FactualConsumer
  CurrentVersion: 2

  constructor: ->
    @app = depend('App')
    @placeDao = depend('dao/place')
    @factualService = depend('FactualService')
    @factualRating = depend('FactualRating')

  geoSearch: (searchParams) ->
    if searchParams.error?
      return Promise.reject(searchParams.error)

    @factualService.geoSearch(searchParams)
    .then (factualPlaces) =>
      #console.log("factual returned #{factualPlaces.length} places")
      @correlateFactualPlaces(factualPlaces)

  correlateFactualPlaces: (factualPlaces) ->
    Assert.type(factualPlaces, Array)

    Promise.all factualPlaces.map (factualPlace) =>
      where = (query) -> query.where({factual_id: factualPlace.factual_id})
      where.factual_id = factualPlace.factual_id
      @placeDao.modifyOrInsert where, (place) =>
        @updatePlaceWithFactualData(place, factualPlace)

  updatePlaceWithFactualData: (place, factualPlace) ->
    place.factual_consume_ver = @CurrentVersion
    place.name = factualPlace.name
    place.factual_id = factualPlace.factual_id
    place.lat = factualPlace.latitude
    place.long = factualPlace.longitude
    place.zipcode = factualPlace.postcode
    place.rating = 0
    place.details =
      address: factualPlace.address
      hours: factualPlace.hours
      tel: factualPlace.tel
      website: factualPlace.website
      price: factualPlace.price
      locality: factualPlace.locality
      region: factualPlace.region
      postcode: factualPlace.postcode
      factual_raw:
        kids_goodfor: factualPlace.kids_goodfor
        kids_menu: factualPlace.kids_menu
        chain_id: factualPlace.chain_id
        chain_name: factualPlace.chain_name
        rating: factualPlace.rating
        smoking: factualPlace.smoking
        options_vegetarian: factualPlace.options_vegetarian
        options_vegan: factualPlace.options_vegan
        options_glutenfree: factualPlace.options_glutenfree
        options_lowfat: factualPlace.options_lowfat
        options_organic: factualPlace.options_organic
        options_healthy: factualPlace.options_healthy
        price: factualPlace.price
        takes_reservations: factualPlace.reservations

    @factualRating.recalculateFactualBasedRating(place)

  refreshOnePlace: (place) =>
    #console.log('FactualConsumer.refreshOnePlace: ', place.place_id)
    @factualService.singlePlace(place.factual_id)
    .then (factualPlace) =>
      @updatePlaceWithFactualData(place, factualPlace)

  refreshOldPlaceData: ->
    # triggered during nightly tasks

    count = 100

    queryFunc = (query) =>
      query.where('factual_consume_ver', '!=', @CurrentVersion)
      query.orWhereNull('factual_consume_ver')
      query.limit(count)

    @placeDao.modifyMulti(queryFunc, @refreshOnePlace)
    .then (results) ->
      console.log("FactualConsumer.refreshOldPlaceData modified #{results.length} places")

provide.class(FactualConsumer)
