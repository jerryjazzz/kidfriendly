
class GooglePlaces
  detailsUrl: 'https://maps.googleapis.com/maps/api/place/details/json'
  photoUrl: 'https://maps.googleapis.com/maps/api/place/photo'
  apiKey: '***REMOVED***'

  constructor: ->
    @http = depend('Http')

  nearbySearch: ({lat, long}) ->
    @http.request
      url: 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      qs:
        key: @apiKey
        types: 'restaurant'
        location: "#{lat},#{long}"

provide.class(GooglePlaces)

provide 'endpoint/api/google', ->

