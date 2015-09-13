
###
  see: https://developers.google.com/places/webservice/search
###

ApiKey = '***REMOVED***'
BrowserApiKey = '***REMOVED***'

provide('google/BrowserApiKey', -> BrowserApiKey)

getprop = (propName) ->
  (obj) ->
    if Array.isArray(obj)
      item[propName] for item in obj
    else
      obj[propName]

normalizeName = (name) ->
  name = name.toUpperCase()
    
  name = name.replace('\'', '')
  name = name.replace('THE ', '')
  name = name.replace('CO.', 'COMPANY')
  name = name.replace('&', 'AND')
  name = name.replace('É', 'E')
  name = name.replace('BBQ', 'BARBEQUE')
  name = name.replace('FINE CHINESE RESTAURANT', '')
  name = name.replace('FINE JAPANESE RESTAURANT', '')
  name = name.replace('RESTAURANT', '')
  name = name.replace('ITALIAN RESTAURANTS', '')

  # keep these steps at the end
  name = name.replace(' ', '')

  return name

class GooglePlaces
  constructor: ->
    @Http = depend('Http')
    @Place = depend('dao/place')
    @PlaceSearch = depend('PlaceSearch')
    @GooglePlace = depend('dao/GooglePlace')
    @GoogleNearbySearchAttempt = depend('dao/GoogleNearbySearchAttempt')
    @GooglePhotos = depend('GooglePhotos')
    @GeomUtil = depend('GeomUtil')
    @Db = depend('db')

  nearbySearch: ({lat, long}) ->
    #console.log('running google place search for: ', {lat,long})

    @Http.request
      url: 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      qs:
        key: ApiKey
        types: 'restaurant'
        location: "#{lat},#{long}"
        rankby: 'distance'

  nearbySearchSave: (params) ->
    @nearbySearch(params)
    .then (response) ->
      #console.log("received #{response.results.length} google results for #{params}")
      response.results
    .map (googleResult) =>
      google_place_id = googleResult.place_id
      @GooglePlace.modifyOrInsert {google_place_id}, (ourGooglePlace) =>
        ourGooglePlace.google_place_id = googleResult.place_id
        ourGooglePlace.lat = googleResult.geometry.location.lat
        ourGooglePlace.long = googleResult.geometry.location.lng
        ourGooglePlace.name = googleResult.name

  correlateGooglePlace2: (googlePlace) =>
    if googlePlace.place_id?
      return {place_id: googlePlace.place_id}

    google_place_id = googlePlace.google_place_id

    console.log('[google] correlating google place: ', {google_place_id})

    @PlaceSearch.geoSearch(lat: googlePlace.lat, long: googlePlace.long, meters: 500)
    .then (places) =>
      matches = (p for p in places when normalizeName(p.name) == normalizeName(googlePlace.name))

      if matches.length > 1
        console.log("warning: multiple matches for #{googlePlace.name}: ", getprop('place_id')(places))

      if (match = matches[0])?

        place_id = match.place_id
        # console.log('found a match ', {name: match.name, place_id, google_place_id})
        @GooglePlace.update2 {google_place_id}, {place_id}
      else
        console.log("no match found for #{googlePlace.name}, candidates were: ", getprop('name')(places))
        {google_place_id, correlate_result: 'not found'}

  runCorrelateJob: (count) ->
    @GooglePlace.find((query) -> query.whereNull('place_id').limit(count))
    .map(@correlateGooglePlace2, {concurrency:1})

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
    # deprecated
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
    # deprecated

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
      select p.place_id,p.lat,p.long from place p left join google_place gp on p.place_id=gp.place_id left join google_nearby_search_attempt gnsa on p.place_id=gnsa.place_id where gp.place_id is null and gnsa.place_id is null
      """)
    .then (result) ->
      console.log("there are #{result.rows.length} places to search")
      result.rows.slice(0, count)

  runCorrelationSearchJob: (count) ->
    @findUncorrelatedPlaces(count)
    .map(@runDirectedSearch, {concurrency:1})

  runDirectedSearch: ({lat, long, place_id}) =>
    console.log('[google] running directed search: ', {place_id})
    result_count = null

    @nearbySearchSave({lat, long})
    .map(@correlateGooglePlace2)
    .then =>
      @GoogleNearbySearchAttempt.modifyOrInsert {place_id}, (directedSearch) ->
        directedSearch.place_id = place_id
        directedSearch.search_at = Timestamp()
    .then ->
      {place_id, result_count}
    .catch (err) ->
      console.log('GooglePlaces.runDirectedSearch failed with: ', err.stack ? err)

provide.class(GooglePlaces)

provide 'admin-endpoint/google', ->
  googleService = depend('GooglePlaces')
  Place = depend('dao/place')
  GooglePlace = depend('dao/GooglePlace')
  GooglePhotos = depend('GooglePhotos')

  resolveLocation = (req) ->
    if req.query.place_id?
      Place.findOne(place_id: req.query.place_id)
      .then (place) ->
        {lat: place.lat, long: place.long}
    else
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

  '/nearby/save': (req) ->
    resolveLocation(req)
    .then (loc) ->
      console.log('loc = ', loc)
      googleService.nearbySearchSave(loc)

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

  '/job/correlate/:count': (req) ->
    googleService.runCorrelateJob(req.params.count)

  '/job/search/:count': (req) ->
    googleService.runCorrelationSearchJob(req.params.count)

  '/find-uncorrelated/:count': (req) ->
    googleService.findUncorrelatedPlaceIds(req.params.count)

