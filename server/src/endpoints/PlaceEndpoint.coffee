
Factual = require('factual-api')
Promise = require('bluebird')

class PlaceEndpoint
  constructor: ->
    @app = depend('App')
    @placeDao = depend('dao/place')
    @placeReviews = depend('PlaceReviews')
    @factualRating = depend('FactualRating')
    get = depend('ExpressGet')
    post = depend('ExpressPost')
    MyPlaceDetails = depend('MyPlaceDetails')

    @route = require('express')()

    get @route, '/:place_id/explain', (req) =>
      {place_id} = req.params
      @placeDao.findById(place_id)
      .then (place) ->
        if not place?
          return {error: "Place not found", place_id: place_id}

        factualRating = depend('FactualRating').getExtendedRating(place)
        {raw: place, factualRating: factualRating}

    get @route, '/:place_id/details', (req) =>
      {place_id} = req.params
      @placeDao.findById(place_id)
      .then (place) ->
        if not place?
          return {error: "Place not found", place_id: place_id}
        place.toClient()
      .then (place) ->
        MyPlaceDetails.maybeAnnotateOne(req, place)

    get @route, '/:place_id/details/reviews', (req) =>
      {place_id} = req.params
      @placeReviews.getWithReviews(place_id)
      .then (place) ->
        if not place?
          return Promise.reject({error: "Place not found", place_id: place_id})
        place.toClient()
      .then (place) ->
        MyPlaceDetails.maybeAnnotateOne(req, place)

    get @route, '/any', (req) =>
      @placeDao.find((query) -> query.limit(1))
      .then (places) ->
        places[0].toClient()

    ###
    post @route, '/new', (req) =>
      manualId = req.body.place_id # usually null
      place =
        place_id: manualId
        name: req.body.name
        location: req.body.location
        google_id: req.body.google_id
        created_at: timestamp()
        source_ver: @app.sourceVersion

      @app.insert('place',place)

    get @route, '/:place_id/rerank', (req) =>

      where = switch
        when req.params.place_id == 'all'
          ->
        else
          (query) -> query.where(place_id: req.params.place_id)

      @placeDao.modifyMulti where, (place) =>
        @factualRating.recalculateFactualBasedRating(place)
    ###


provide.class('endpoint/api/place', PlaceEndpoint)

provide 'admin-endpoint/place', ->
  Place = depend('dao/place')
  FactualService = depend('FactualService')

  '/:place_id/factual': (req) ->
    Place.findById(req.params.place_id)
    .then (place) ->
      FactualService.singlePlace(place.factual_id)

  '/:place_id/factual/refresh': (req) ->
    Place.findById(req.params.place_id)
    .then (place) ->
      FactualService.singlePlace(place.factual_id)
    
