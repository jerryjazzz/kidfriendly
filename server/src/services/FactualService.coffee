
Promise = require('bluebird')
querystring = require('querystring')

class FactualService
  queryLimit: 50 # max allowed by factual

  # joe's key:
  key: '***REMOVED***'
  secret: '***REMOVED***'

  constructor: ->
    @app = depend('App')
    @placeDao = depend('dao/place')
    @placeSearch = depend('PlaceSearch')

    lib = require('factual-api')
    @api = new lib(@key, @secret)
    #@api.startDebug()

  _apiGet: (uri, args) ->
    new Promise (resolve, reject) =>
      @api.get uri, args, (error, res) =>
        if error?
          reject(error)
        else
          resolve(res)

  factualOptions: (searchParams) ->
    if searchParams.toGeoLocation?
      searchParams = searchParams.toGeoLocation()

    {lat, long, meters, error} = searchParams
    if error?
      return {error}

    Assert.notNull(lat, 'lat')
    Assert.notNull(long, 'long')
    Assert.notNull(meters, 'meters')

    {
      filters:
        category_ids: {'$includes': 347} # restaurants
      geo:
        $circle:
          $center: [lat, long]
          $meters: meters
      limit: @queryLimit
    }

  geoSearch: (searchParams) ->
    options = @factualOptions(searchParams)
    if options.error?
      return Promise.reject(options.error)

    @_apiGet('/t/restaurants-us', options)
      .then (result) =>
        result.data

  getUrl: (searchParams) ->
    factualOptions = @factualOptions(searchParams)
    params = {}
    for k,v of factualOptions
      params[k] = JSON.stringify(v)
    params.KEY = @key
    return {
      url: "http://api.v3.factual.com/t/restaurants-us?#{querystring.stringify(params)}"
    }

  singlePlace: (factual_id) ->
    url = '/t/restaurants-us/' + factual_id
    @_apiGet(url)
    .then (results) ->
      return results.data[0]
    .catch (err) ->
      console.log("Factual returned error for #{url}: ", err)
      null

provide.class(FactualService)
