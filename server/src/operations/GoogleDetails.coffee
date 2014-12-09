
class GoogleDetails
  constructor: (@app) ->

  start: ({place_id}) ->
    @app.db.select('google_id').from('place').where({place_id})
    .then (result) =>
      if not result[0]?
        {}
      else
        @sendGoogleRequest(place_id, result[0].google_id)

  sendGoogleRequest: (placeId, googleId) =>
    url = GoogleApi.detailsUrl + "?key=#{GoogleApi.apiKey}&placeid=#{googleId}"
    @app.request(url: url)
    .then (googlePlace) =>
      GoogleApi.convertPlaceResult(placeId, googlePlace.result)
