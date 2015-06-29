
provide 'admin-endpoint/factual', ->
  FactualService = depend('FactualService')
  FactualConsumer = depend('FactualConsumer')

  '/geo': (req) ->
    {lat, long, meters, zipcode} = req.query
    FactualService.geoSearch({lat, long, meters, zipcode})

  '/consume/geo': (req) ->
    {lat, long, meters, zipcode} = req.query
    FactualConsumer.geoSearch({lat, long, meters, zipcode})

  '/details/:factual_id': (req) ->
    {factual_id} = req.params
    FactualService.singlePlace(factual_id)
