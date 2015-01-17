
Promise = require('bluebird')

class Factual
  key: '1sUYzGaNl6TXzo5OxhuZOT66CLeNvuKm8EWUxcw9'
  secret: 'jcBFMYznXVRcq6ozYRUrasE1OGrmhXWPLS5AWiZo'

  constructor: (@app) ->
    lib = require('factual-api')
    @api = new lib(@key, @secret)

  _getPlaces: (args) ->
    new Promise (resolve, reject) =>
      @api.get '/t/places-us', args, (error, res) =>
        if error?
          reject(error)
        else
          resolve(res)

  geoSearch: ({lat, long, range}) ->
    options =
      filters:
        category_ids: {'$includes': 347} # restaurants
      geo:
        $circle:
          $center: [lat, long]
          $meters: range

    @_getPlaces(options)
      .then (results) =>
        @correlateFactualPlaces(results.data)

  handleExistingFactualPlace: (factualPlace, ourPlace) ->
    @app.log("found existing factual place: #{factualPlace.factual_id}")
    # TODO: Check if ourPlace data is out-of-date and needs updating.

  handleMissingFactualPlace: (factualPlace) ->
    @app.log("adding missing factual place: #{factualPlace.factual_id}")
    placeData =
      name: factualPlace.name
      factual_id: factualPlace.factual_id
      details: JSON.stringify
        address: factualPlace.address
        hours: factualPlace.hours
        lat: factualPlace.latitude
        long: factualPlace.longitude
        tel: factualPlace.tel
        website: factualPlace.website

    @app.insert('place', placeData)

  correlateFactualPlaces: (factualPlaces) ->
    Expect.type(factualPlaces, Array)
    
    # 'factualPlaces' is a list of results from factual
    # output: {
    #   found: (map of factual_id -> place_id)
    #   not_found: (list of factual results)
    # }
    #
    query = @app.db.select('place_id','factual_id').from('place')

    for factualPlace in factualPlaces
      factual_id = factualPlace.factual_id
      Expect.notNull(factual_id)
      query.orWhere({factual_id})

    query.then (results) =>
      foundPlaces = Map.fromList(results, 'factual_id')

      ops = for factualPlace in factualPlaces
        found = foundPlaces[factualPlaces.factual_id]
        if found?
          @handleExistingFactualPlace(factualPlace, found)
        else
          @handleMissingFactualPlace(factualPlace)

      Promise.all(ops)





