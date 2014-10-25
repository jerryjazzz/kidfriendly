
Promise = require('bluebird')

class GooglePlaces
  apiKey: '***REMOVED***'
  nearbySearchUrl: 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'

  searchTypes:
    restaurant:
      typeString: 'cafe|food|restaurant'

  defaultRadius: 15000 # meters

  constructor: (@app) ->

  nearby: ({searchType, location, radius}) ->
    new Promise (resolve, reject) =>
      searchType = @searchTypes[searchType]

      if not searchType?
        throw new Error("unrecognized search type: #{searchType}")

      radius = radius ? @defaultRadius

      url = "#{@nearbySearchUrl}?key=#{@apiKey}&type=#{searchType.typeString}"
      url += "&location=#{location.lat},#{location.long}&radius=#{radius}"
      request = require('request')
      request {url, json:true}, (error, response, body) =>
        if error?
          return reject(error)

        resolve(body.results)
