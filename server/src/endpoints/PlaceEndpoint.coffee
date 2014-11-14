
class PlaceEndpoint
  constructor: (@app) ->
    wrap = (f) -> ExpressUtil.wrap({}, f)

    @endpoint = require('express')()

    @endpoint.get '/:place_id/details', wrap (req) =>
      "todo"

    @endpoint.post '/:place_id/delete', wrap (req) =>
      # SECURITY_TODO: Verify permission to delete
      "todo"
      @app.query("delete from place where place_id = ?", [req.params.place_id]).then -> {}

    @endpoint.post '/from_google_id/:google_id/delete', wrap (req) =>
      # SECURITY_TODO: Verify permission to delete
      "todo"
      @app.query("delete from place where google_id = ?", [req.params.google_id]).then -> {}

    @endpoint.post '/new', wrap (req) =>
      manualId = req.body.place_id # usually null
      place =
        place_id: manualId
        name: req.body.name
        location: req.body.location
        google_id: req.body.google_id
        created_at: DateUtil.timestamp()
        source_ver: @app.sourceVersion

      @app.insert("place", place)
        .then (row) -> {place_id} = row
