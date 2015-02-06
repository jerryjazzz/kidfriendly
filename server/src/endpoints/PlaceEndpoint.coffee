
Factual = require('factual-api')

class PlaceEndpoint
  constructor: ->
    @app = depend('App')
    @placeDao = depend('PlaceDAO')

    wrap = (f) -> ExpressUtil.wrap({}, f)

    @route = require('express')()

    @route.get '/:place_id/details', wrap (req) =>
      {place_id} = req.params
      @placeDao.get((query) -> query.where({place_id}))
      .then (places) ->
        place = places[0]
        if place?
          place = place.toClient()
        place

    @route.post '/:place_id/delete', wrap (req) =>
      # SECURITY_TODO: Verify permission to delete
      "todo"
      @app.db('place').where({place_id:req.params.place_id}).delete()
      .then -> {}

    @route.post '/from_google_id/:google_id/delete', wrap (req) =>
      # SECURITY_TODO: Verify permission to delete
      "todo"
      @app.db('place').where({google_id:req.params.google_id}).delete()
      .then -> {}

    @route.get '/any', wrap (req) =>
      @placeDao.get((query) -> query.limit(1))

    @route.post '/new', wrap (req) =>
      manualId = req.body.place_id # usually null
      place =
        place_id: manualId
        name: req.body.name
        location: req.body.location
        google_id: req.body.google_id
        created_at: DateUtil.timestamp()
        source_ver: @app.sourceVersion

      @app.insert('place',place)

    Get @route, '/:place_id/rerank', {}, (req) =>
      @app.db.select('*').from('place').where({place_id: req.params.place_id})
      .then (rows) ->
        place = rows[0]
        console.log('place = ', rows[0])

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
