
Factual = require('factual-api')

class PlaceEndpoint
  constructor: ->
    @app = depend('App')
    @placeDao = depend('PlaceDAO')
    @factualRating = depend('FactualRating')
    get = depend('ExpressGet')
    post = depend('ExpressPost')

    @route = require('express')()

    get @route, '/:place_id/explain', (req) =>
      {place_id} = req.params
      @placeDao.getId(place_id)
      .then (place) ->
        if not place?
          return {error: "Place not found", place_id: place_id}

        factualRating = depend('FactualRating').getExtendedRating(place)
        {raw: place, factualRating: factualRating}

    get @route, '/:place_id/details', (req) =>
      {place_id} = req.params
      @placeDao.getId(place_id)
      .then (place) ->
        if not place?
          return {error: "Place not found", place_id: place_id}
        place.toClient()

    get @route, '/:place_id/details/reviews', (req) =>
      {place_id} = req.params
      @placeDao.getWithReviews(place_id)
      .then (place) ->
        if place?
          place.toClient()
        else
          {error: "Place not found", place_id: place_id}

    post @route, '/:place_id/delete', (req) =>
      # SECURITY_TODO: Verify permission to delete
      "todo"
      @app.db('place').where({place_id:req.params.place_id}).delete()
      .then -> {}

    post @route, '/from_google_id/:google_id/delete', (req) =>
      # SECURITY_TODO: Verify permission to delete
      "todo"
      @app.db('place').where({google_id:req.params.google_id}).delete()
      .then -> {}

    get @route, '/any', (req) =>
      @placeDao.get((query) -> query.limit(1))
      .then (places) ->
        places[0].toClient()

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

      placeIds = switch
        when req.params.place_id == 'all'
          @app.db.select('place_id').from('place')
          .then (rows) ->
            row.place_id for row in rows
        else
          [req.params.place_id]

      Promise.resolve(placeIds)
      .map (placeId) =>
        @placeDao.modify placeId, (place) =>
          @factualRating.recalculateFactualBasedRating(place)
        .then (place) ->
          {place_id:place.place_id, name: place.name, rating:place.rating}

provide('PlaceEndpoint', PlaceEndpoint)
