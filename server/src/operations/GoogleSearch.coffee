
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
    console.log('googleResults = ', @googleResults)

    whereStrs = for id, place of @googleResults
      @app.sqlFormat("google_id = ?", [place.place_id])

    if whereStrs.length == 0
      return []
    
    @app.query("select place_id,google_id from place where #{whereStrs.join(' or ')}")
    .then (results) =>
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
      photoUrl = null
      if (googlePhoto = googlePlace.photos?[0])?
        photoUrl = "#{GoogleApi.photoUrl}?maxwidth=88&photoreference=#{googlePhoto.photo_reference}&key=#{GoogleApi.browserApiKey}"

      # TEMP: Hide results with no photo
      if not photoUrl?
        continue
      
      {
        place_id: googlePlace.kfly_id
        name: googlePlace.name
        location: googlePlace.location
        thumbnail_url: photoUrl
        open_now: googlePlace?.opening_hours?.open_now ? false
        rating: parseFloat(googlePlace.rating) * 20
        price_level: googlePlace.price_level
      }


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

