
class SubmitEndpoint
  constructor: (@app) ->
    @endpoint = require('express')()

    withRequiredParams = (params, next) ->
      (req, res) ->
        for param in params
          if not req.query[param]?
            res.status(400).send("'#{param}' param is required")
            return

        next(req, res)

    @endpoint.get '/location', withRequredParams ['loc'], (req, res) =>
      location = LatLongUtil.parse(req.query.loc)

      @app.libs.googlePlaces.nearby({searchType: 'restaurant', location})
        .catch (err) ->
          res.status(400).send(err)
        .then (places)
          res.status(200).send(places)
