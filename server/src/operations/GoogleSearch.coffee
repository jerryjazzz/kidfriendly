
class GoogleSearch

  defaultRadius: 15000 # meters

  constructor: (@app) ->
    @googleResults = null # keyed by google_id

  start: ({nearby}) ->
    googleRequest = switch
      when nearby?
        @requestNearby(nearby)

    googleRequest.then (results) =>
      @googleResults = {}
      for place in results
        place.location = "#{place.geometry.location.lat},#{place.geometry.location.lng}"
        @googleResults[place.place_id] = place

    .then =>
      @findExistingIdsAndSaveNew()
    .then =>
      @formatResults()

  requestNearby: ({type, location, keyword, radius}) ->
    if not type? then throw new Error("missing type")
    if not location? then throw new Error("missing location")

    if not keyword? and not radius?
      radius = @defaultRadius

    url = "#{GoogleApi.nearbySearchUrl}?key=#{GoogleApi.apiKey}&types=#{type}"
    url += "&location=#{location}"
    if radius?
      url += "&radius=#{radius}"
    if keyword?
      url += "&keyword=#{keyword}&rankby=distance"

    @app.request(url: url, json: true)
    .then (body) -> body.results

  findExistingIdsAndSaveNew: ->
    googleIds = (place.place_id for id, place of @googleResults)

    if googleIds.length == 0
      return []

    query = @app.db.select('place_id','google_id').from('place')

    for google_id in googleIds
      query.orWhere({google_id})
    
    query.then (results) =>
      for {place_id, google_id} in results
        @googleResults[google_id].kfly_id = place_id

      @saveNewPlaces(googlePlace for id,googlePlace of @googleResults when not googlePlace.kfly_id?)

  saveNewPlaces: (googlePlaces) ->
    Promise.all googlePlaces.map (googlePlace) =>
      @app.insert "place",
        name: googlePlace.name
        google_id: googlePlace.place_id
        created_at: DateUtil.timestamp()
        source_ver: @app.sourceVersion
        location: googlePlace.location
      .then ({id}) =>
        googlePlace.kfly_id = id

  formatResults: ->
    for id, googlePlace of @googleResults
      GoogleApi.convertPlaceResult(googlePlace.kfly_id, googlePlace)

# Stuff to store:
# thumbnail_url
# rating
# type
# cost
# hours
# open now?

###

Searches
  Nearby (long/lat)
  Keyword for specific cuisine

Return
  name
  location
  place_id
  cost
  hours
  open now?
  thumbnail_url
###

