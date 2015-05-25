
class UserAnnotatedSearchResults
  constructor: ->
    @userDao = depend('UserDAO')
    @voteDao = depend('VoteDAO')

  annotate: (places, user_id) ->
    placeIds = (place.place_id for place in places)

    @voteDao.find (query) ->
      query.where({user_id})
      query.whereIn('place_id', placeIds)
    .then (votes) ->
      votesByPlaceId = {}
      for vote in votes
        votesByPlaceId[vote.place_id] = vote.vote

      for place in places
        if (vote = votesByPlaceId[place.place_id])?
          place.me = place.me ? {}
          place.me.vote = vote

      places

provide.class(UserAnnotatedSearchResults)
