
ApiKey = '***REMOVED***'
BrowserApiKey = '***REMOVED***'

provide('google/BrowserApiKey', -> BrowserApiKey)

class GooglePlaces
  constructor: ->
    @Http = depend('Http')
    @Place = depend('dao/place')
    @GooglePlace = depend('dao/GooglePlace')
    @GooglePhotos = depend('GooglePhotos')
    @GeomUtil = depend('GeomUtil')
    @Sector = depend('dao/sector')
    @SectorService = depend('SectorService')

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

  runSectorSearchJob: (sectorCount) ->
    @Sector.find((query) -> query.whereNull('google_search_at').whereNotNull('factual_search_at').limit(sectorCount))
    .map(@searchAndSaveForSector)

  runDetailsRequestJob: (count) ->
    @GooglePlace.find((query) -> query.whereNull('details_request_at').limit(count))
    .map(@saveDetailsForGooglePlace)

  searchAndSaveForSector: (sector) =>
    sector_id = sector.sector_id
    found_count = null

    @nearbySearch({lat: sector.lat,long: sector.long})
    .then (response) ->
      results = response.results
      found_count = results.length
      results
    .map (googleResult) =>
      @correlateAndSaveGooglePlace(googleResult)
    .then =>
      @Sector.update2({sector_id}, {google_search_at: Timestamp(), google_search_count: found_count})

  correlateAndSaveGooglePlace: (googleResult) ->
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
      results.filter(closeEnough)

    .then (results) ->
      if results.length == 0
        console.log("[google correlate] No local place found for google place, name = #{googleResult.name}, "+\
          "google_place_id = #{google_place_id}")
        return null
      else if results.length > 1
        console.log("[google correlate] Multiple local places found for google place, name = #{googleResult.name}, "+\
          "google_place_id = #{google_place_id}, matches = #{p.id for p in results}")
        return null
      else
        # Found 1 result
        console.log("[google correlate] One result found for #{googleResult.name}: ", results[0].place_id)
        return results[0]

provide.class(GooglePlaces)

provide 'admin-endpoint/google', ->
  googleService = depend('GooglePlaces')
  SectorService = depend('SectorService')
  GooglePlace = depend('dao/GooglePlace')
  GooglePhotos = depend('GooglePhotos')

  resolveLocation = (req) ->
    Promise.resolve()
    .then ->
      if req.query.sector_id?
        SectorService.sectorToLatLong(req.query.sector_id)
      else
        {lat: req.query.lat, long: req.query.long}

  '/nearby': (req) ->
    resolveLocation(req)
    .then (loc) ->
      googleService.nearbySearch(loc)
    .then (response) ->
      response.results

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
    console.log('count = ', req.params.count)
    googleService.runDetailsRequestJob(req.params.count)

  '/job/sector-search/:count': (req) ->
    console.log('count = ', req.params.count)
    googleService.runSectorSearchJob(req.params.count)
