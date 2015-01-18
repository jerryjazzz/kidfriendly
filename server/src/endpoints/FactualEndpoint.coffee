
class FactualEndpoint
  constructor: ->
    @route = require('express')()
    @app = depend('App')
    @factualService = depend('FactualService')
    @factualConsumer = depend('FactualConsumer')

    Get @route, '/geo', {}, (req) =>
      {lat, long, meters, zipcode} = req.query
      @factualService.geoSearch({lat, long, meters, zipcode})

    Get @route, '/consume/geo', {}, (req) =>
      {lat, long, meters, zipcode} = req.query
      @factualConsumer.geoSearch({lat, long, meters, zipcode})

    Get @route, '/details/:factual_id', {}, (req) =>
      @app.log(req.query)
      {factual_id} = req.params
      @factualService.placeDetails(factual_id)

  @create: (app) ->
    (new FactualEndpoint(app)).route
