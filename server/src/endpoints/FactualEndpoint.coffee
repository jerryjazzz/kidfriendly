
provide 'admin-endpoint/factual', ->
  FactualService = depend('FactualService')
  FactualConsumer = depend('FactualConsumer')
  Sector = depend('dao/sector')

  '/geo': (req) ->
    {lat, long, meters, zipcode} = req.query
    FactualService.geoSearch({lat, long, meters, zipcode})

  '/consume/geo': (req) ->
    {lat, long, meters, zipcode} = req.query
    FactualConsumer.geoSearch({lat, long, meters, zipcode})

  '/consume/sector/:sector_id': (req) ->
    Sector.findById(req.params.sector_id)
    .then (sector) ->
      FactualConsumer.sectorSearch(sector)

  '/details/:factual_id': (req) ->
    {factual_id} = req.params
    FactualService.singlePlace(factual_id)
