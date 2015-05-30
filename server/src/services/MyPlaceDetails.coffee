
class MyPlaceDetails
  constructor: ->
    @Vote = depend('dao/vote')
    @UserAuthentication = depend('UserAuthentication')

  maybeAnnotate: (req, places) =>
    @UserAuthentication.fromRequest(req)
    .then (user) =>
      if user?
        @annotate(places, user.user_id)
      else
        places

  maybeAnnotateOne: (req, place) ->
    @maybeAnnotate(req, [place])
    .then (places) ->
      places[0]

  annotate: (places, user_id) ->
    placeIds = (place.place_id for place in places)

    @Vote.find (query) ->
      query.where({user_id})
      query.whereIn('place_id', placeIds)
    .then (votes) ->
      votesByPlaceId = {}
      for vote in votes
        votesByPlaceId[vote.place_id] = vote.vote

      for place in places
        place.me = place.me ? {}
        place.me.vote = votesByPlaceId[place.place_id] ? 0

      places

provide.class(MyPlaceDetails)
