
###
  see: https://developers.google.com/places/webservice/search
###

ApiKey = '***REMOVED***'
BrowserApiKey = '***REMOVED***'

provide('google/BrowserApiKey', -> BrowserApiKey)

class GooglePlaces
  constructor: ->
    @Http = depend('Http')
    @Place = depend('dao/place')
    @GooglePlace = depend('dao/GooglePlace')
    @GoogleNearbySearchAttempt = depend('dao/GoogleNearbySearchAttempt')
    @GooglePhotos = depend('GooglePhotos')
    @GeomUtil = depend('GeomUtil')
    @Db = depend('db')

  nearbySearch: ({lat, long}) ->
    @Http.request
      url: 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      qs:
        key: ApiKey
        types: 'restaurant'
        location: "#{lat},#{long}"
        rankby: 'distance'

  requestDetails: (google_place_id) ->
    @Http.request
      url: 'https://maps.googleapis.com/maps/api/place/details/json'
      qs:
        placeid: google_place_id
        key: ApiKey

  saveDetailsForGooglePlace: (google_place) =>
    new_google_place = null

    @requestDetails(google_place.google_place_id)
    .then (response) =>

      details = response.result

      new_google_place =
        place_id: google_place.place_id
        details_request_at: Timestamp()
        details: details

      @GooglePlace.update2(place_id: google_place.place_id, new_google_place)
    .then =>
      @GooglePhotos.savePhotosForPlace(google_place.place_id, new_google_place.details)
    .then =>
      new_google_place

  runDetailsRequestJob: (count) ->
    @GooglePlace.find((query) -> query.whereNull('details_request_at').limit(count))
    .map(@saveDetailsForGooglePlace, {concurrency: 1})

  correlateAndSaveGooglePlace: (googleResult) =>
    google_place_id = googleResult.place_id

    @GooglePlace.findOne({google_place_id})
    .then (existing) =>
      if existing?
        return {result: 'already_have', google_place_id, place_id: existing.place_id}

      @correlateGoogleResult(googleResult)
      .then (place) =>
        if not place?
          return {result: 'local_place_not_found', google_place_id, name: googleResult.name}

        if not place.place_id?
          throw new Error('place_id is missing?')

        @GooglePlace.insert({place_id: place.place_id, google_place_id})
        .then ->
          {result: 'success', place_id: place.place_id}

  correlateGoogleResult: (googleResult) ->

    location =
      lat: googleResult.geometry.location.lat
      long: googleResult.geometry.location.lng

    maxMeters = 500

    closeEnough = @GeomUtil.closerThan(location, maxMeters)

    google_place_id = googleResult.place_id

    @Place.find(name: googleResult.name)
    .then (results) ->
      if null in results
        console.log("null in results? searching for name: #{name}, results: #{results}")
      results.filter(closeEnough)

    .then (results) ->
      if results.length == 0
        console.log("[google correlate] No local place found, name = #{googleResult.name}, "+\
          "google_place_id = #{google_place_id}")
        return null
      else if results.length > 1
        console.log("[google correlate] Multiple local places found, name = #{googleResult.name}, "+\
          "google_place_id = #{google_place_id}, matches = #{p.id for p in results}")
        return null
      else
        # Found 1 result
        return results[0]

  findUncorrelatedPlaces: (count) ->
    # Returns {place_id, lat, long}

    @Db.raw("""
      select place_id,lat,long from place where not exists
      (select * from google_place,google_nearby_search_attempt where google_place.place_id = place.place_id
        or google_nearby_search_attempt.place_id = place.place_id)
      limit ?
      """, count)
    .then (result) ->
      result.rows

  runCorrelationSearchJob: (count) ->
    @findUncorrelatedPlaces(count)
    .map(@runDirectedSearch, {concurrency:1})

  runDirectedSearch: ({lat, long, place_id}) =>
    result_count = null

    @nearbySearch({lat, long})
    .then (response) ->
      result_count = response.results.length
      response.results
    .map (googleResult) =>
      @correlateAndSaveGooglePlace(googleResult)
    .then =>
      @GoogleNearbySearchAttempt.modifyOrInsert {place_id}, (directedSearch) ->
        directedSearch.place_id = place_id
        directedSearch.search_at = Timestamp()
    .then ->
      {place_id, result_count}
    .catch (err) ->
      console.log('GooglePlaces.runDirectedSearch failed with: ', err)

provide.class(GooglePlaces)

provide 'admin-endpoint/google', ->
  googleService = depend('GooglePlaces')
  GooglePlace = depend('dao/GooglePlace')
  GooglePhotos = depend('GooglePhotos')

  resolveLocation = (req) ->
    # this function once did more stuff
    {lat: req.query.lat, long: req.query.long}

  '/nearby': (req) ->
    resolveLocation(req)
    .then (loc) ->
      googleService.nearbySearch(loc)

  '/cached-place/any': (req) ->
    GooglePlace.find((query) -> query.limit(1))

  '/cached-place/:place_id': (req) ->
    GooglePlace.findById(req.params.place_id)
    
  '/cached-place/:place_id/consume': (req) ->
    GooglePlace.findById(req.params.place_id)
    .then (googlePlace) ->
      googleService.saveDetailsForGooglePlace(googlePlace)

  '/cached-place/:place_id/details': (req) ->
    GooglePlace.findById(req.params.place_id)
    .then (googlePlace) ->
      googlePlace.details

  '/cached-place/:place_id/photos': (req) ->
    GooglePlace.findById(req.params.place_id)
    .then (googlePlace) ->
      for photo in googlePlace.details.photos
        GooglePhotos.photoReferenceUrl({width: photo.width, height: photo.height}, photo.photo_reference)

  '/details/:google_place_id': (req) ->
    googleService.requestDetails(req.params.google_place_id)
    .then (response) ->
      response.result

  '/consume-details/:place_id': (req) ->
    GooglePlace.findById(req.params.place_id)
    .then (googlePlace) ->
      googleService.saveDetailsForGooglePlace(googlePlace)

  '/nearby/correlate': (req) ->
    resolveLocation(req)
    .then (loc) ->
      googleService.nearbySearch(loc)
    .then (response) ->
      response.results
    .map (googleResult) ->
      googleService.correlateAndSaveGooglePlace(googleResult)

  '/job/details-request/:count': (req) ->
    googleService.runDetailsRequestJob(req.params.count)

  '/job/correlation-search/:count': (req) ->
    googleService.runCorrelationSearchJob(req.params.count)

  '/find-uncorrelated/:count': (req) ->
    googleService.findUncorrelatedPlaceIds(req.params.count)

