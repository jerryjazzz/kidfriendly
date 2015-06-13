
class GooglePlaces
  photoUrl: 'https://maps.googleapis.com/maps/api/place/photo'
  apiKey: '***REMOVED***'

  constructor: ->
    @Http = depend('Http')
    @Place = depend('dao/place')
    @GooglePlace = depend('dao/GooglePlace')
    @GeomUtil = depend('GeomUtil')

  nearbySearch: ({lat, long}) ->
    @Http.request
      url: 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      qs:
        key: @apiKey
        types: 'restaurant'
        location: "#{lat},#{long}"
        rankby: 'distance'

  details: (place_id) ->
    @Http.request
      url: 'https://maps.googleapis.com/maps/api/place/details/json'
      qs:
        placeid: place_id
        key: @apiKey

  correlateAndSaveGooglePlace: (googlePlace) ->
    google_place_id = googlePlace.place_id

    @GooglePlace.findOne({google_place_id})
    .then (existing) =>
      if existing?
        return {result: 'already_have', google_place_id, place_id: existing.place_id}

      @correlateGooglePlace(googlePlace)
      .then (place) =>
        if not place?
          return {result: 'local_place_not_found', google_place_id, name: googlePlace.name}

        if not place.place_id?
          throw new Error('place_id is missing?')

        @GooglePlace.insert({place_id: place.place_id, google_place_id})
        .then ->
          {result: 'success', place_id: place.place_id}

  correlateGooglePlace: (googlePlace) ->

    location =
      lat: googlePlace.geometry.location.lat
      long: googlePlace.geometry.location.lng

    maxMeters = 500

    closeEnough = @GeomUtil.closerThan(location, maxMeters)

    google_place_id = googlePlace.place_id

    @Place.find(name: googlePlace.name)
    .then (results) ->
      console.log("[google correlate] found #{results.length} places for #{googlePlace.name}")
      results.filter(closeEnough)

    .then (results) ->
      if results.length == 0
        console.log("[google correlate] No local place found for google place, name = #{googlePlace.name}, "+\
          "google_place_id = #{google_place_id}")
        return null
      else if results.length > 1
        console.log("[google correlate] Multiple local places found for google place, name = #{googlePlace.name}, "+\
          "google_place_id = #{google_place_id}, matches = #{p.id for p in results}")
        return null
      else
        # Found 1 result
        console.log("[google correlate] One result found for #{googlePlace.name}: ", results[0].place_id)
        return results[0]

provide.class(GooglePlaces)

provide 'admin-endpoint/google', ->
  googlePlaces = depend('GooglePlaces')

  '/nearby': (req) ->
    googlePlaces.nearbySearch(req.query)
    .then (answer) ->
      answer.results

  '/details/:google_place_id': (req) ->
    googlePlaces.details(req.params.google_place_id)
    .then (answer) ->
      answer.result

  '/nearby/correlate': (req) ->
    googlePlaces.nearbySearch(req.query)
    .then (answer) ->
      answer.results
    .map (googlePlace) ->
      googlePlaces.correlateAndSaveGooglePlace(googlePlace)

