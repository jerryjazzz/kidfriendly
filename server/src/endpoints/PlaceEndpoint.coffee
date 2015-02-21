
Factual = require('factual-api')

class PlaceEndpoint
  constructor: ->
    @app = depend('App')
    @placeDao = depend('PlaceDAO')
    get = depend('ExpressGet')
    post = depend('ExpressPost')

    @route = require('express')()

    get @route, '/:place_id/details', (req) =>
      {place_id} = req.params
      @placeDao.get((query) -> query.where({place_id}))
      .then (places) ->
        if places[0]?
          places[0].toClient()
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

    post @route, '/new', (req) =>
      manualId = req.body.place_id # usually null
      place =
        place_id: manualId
        name: req.body.name
        location: req.body.location
        google_id: req.body.google_id
        created_at: DateUtil.timestamp()
        source_ver: @app.sourceVersion

      @app.insert('place',place)

    get @route, '/:place_id/rerank', (req) =>
      @app.db.select('*').from('place').where({place_id: req.params.place_id})
      .then (rows) ->
        place = rows[0]

        log = []

        depend('FactualConsumer').recalculateFactualBasedRanking
          place: place
          trace: (label, arg) ->
            log += "#{label}: #{arg}"

        @app.db('place').where({place_id}).update(place)
        .then ->
          return log

  @create: (app) ->
    (new PlaceEndpoint(app)).route
