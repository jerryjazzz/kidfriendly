
class FactualEndpoint
  constructor: ->
    @route = require('express')()
    @app = depend('App')
    @factualService = depend('FactualService')
    @factualConsumer = depend('FactualConsumer')
    get = depend('ExpressGet')

    get @route, '/geo', (req) =>
      {lat, long, meters, zipcode} = req.query
      @factualService.geoSearch({lat, long, meters, zipcode})

    get @route, '/consume/geo', (req) =>
      {lat, long, meters, zipcode} = req.query
      @factualConsumer.geoSearch({lat, long, meters, zipcode})

    get @route, '/details/:factual_id', (req) =>
      @app.log(req.query)
      {factual_id} = req.params
      @factualService.singlePlace(factual_id)

provide('endpoint/api/factual', FactualEndpoint)
