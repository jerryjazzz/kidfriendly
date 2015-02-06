
Promise = require('bluebird')

class FactualService
  # joe's key:
  key: '***REMOVED***'
  secret: '***REMOVED***'

  constructor: ->
    @app = depend('App')
    @placeDao = depend('PlaceDAO')
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

  geoSearch: (searchOptions) ->
    @placeSearch.resolveZipcode(searchOptions)
    {lat, long, meters} = searchOptions
    Assert.notNull(lat, 'lat')
    Assert.notNull(long, 'long')
    Assert.notNull(meters, 'meters')

    options =
      filters:
        category_ids: {'$includes': 347} # restaurants
      geo:
        $circle:
          $center: [lat, long]
          $meters: meters
          $meters: meters

    @_apiGet('/t/restaurants-us', options)
      .then (result) =>
        result.data

  singlePlace: (factual_id) ->
    @_apiGet('/t/restaurants-us/' + factual_id)
      .then (results) ->
        return results.data[0]

provide('FactualService', FactualService)
