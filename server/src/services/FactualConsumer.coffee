'use strict'

Promise = require('bluebird')

class FactualConsumer
  CurrentVersion: 1

  constructor: ->
    @app = depend('App')
    @placeDao = depend('PlaceDAO')
    @factualService = depend('FactualService')
    @factualRating = depend('FactualRating')

  geoSearch: (options) ->
    @factualService.geoSearch(options)
    .then (factualPlaces) =>
      #console.log("factual returned #{factualPlaces.length} places")
      @correlateFactualPlaces(factualPlaces)

  correlateFactualPlaces: (factualPlaces) ->
    Assert.type(factualPlaces, Array)
   
    @placeDao.get (query) ->
      for factualPlace in factualPlaces
        factual_id = factualPlace.factual_id
        Assert.notNull(factual_id)
        query.orWhere({factual_id})

    .then (places) =>
      foundPlaces = Map.fromList(places, 'factual_id')

      ops = for factualPlace in factualPlaces
        foundPlace = foundPlaces[factualPlace.factual_id]
        if foundPlace?
          @app.log("updating place #{foundPlace.place_id} with factual #{factualPlace.factual_id}")

          #console.log('factualPlace = ', JSON.stringify(factualPlace))
          #console.log('foundPlace = ', JSON.stringify(foundPlace))

          # TODO: use PlaceDAO.modify instead.
          place = foundPlace.startPatch()
          @updatePlaceWithFactualData(place, factualPlace)
          @placeDao.save(place)
          {place_id: place.place_id, name: factualPlace.name}

        else
          @app.log("adding missing factual place: #{factualPlace.factual_id}")
          place = depend('newPlace')({})
          @updatePlaceWithFactualData(place, factualPlace)
          @placeDao.insert(place)

      Promise.all(ops)

  updatePlaceWithFactualData: (place, factualPlace) ->
    place.factual_consume_ver = @CurrentVersion
    place.name = factualPlace.name
    place.factual_id = factualPlace.factual_id
    place.lat = factualPlace.latitude
    place.long = factualPlace.longitude
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

provide('FactualConsumer', FactualConsumer)
