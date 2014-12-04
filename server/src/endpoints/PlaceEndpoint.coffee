
class PlaceEndpoint
  constructor: (@app) ->
    wrap = (f) -> ExpressUtil.wrap({}, f)

    @endpoint = require('express')()

    @endpoint.get '/:place_id/details', wrap (req) =>
      operation = new GoogleDetails(@app)
      operation.start(place_id: req.params.place_id)

    @endpoint.post '/:place_id/delete', wrap (req) =>
      # SECURITY_TODO: Verify permission to delete
      "todo"
      @app.db('place').where({place_id:req.params.place_id}).delete()
      .then -> {}

    @endpoint.post '/from_google_id/:google_id/delete', wrap (req) =>
      # SECURITY_TODO: Verify permission to delete
      "todo"
      @app.db('place').where({google_id:req.params.google_id}).delete()
      .then -> {}

    @endpoint.post '/new', wrap (req) =>
      manualId = req.body.place_id # usually null
      place =
        place_id: manualId
        name: req.body.name
        location: req.body.location
        google_id: req.body.google_id
        created_at: DateUtil.timestamp()
        source_ver: @app.sourceVersion

      @app.insert('place',place)
