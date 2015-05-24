
Promise = require('bluebird')

class VoteService
  constructor: ->
    @db = depend('db')
    @voteDao = depend('VoteDAO')
    @placeDao = depend('PlaceDAO')

  recalculateForPlace: (place_id) ->
    Promise.props
      upvote_count: @voteDao.count((query) -> query.where({place_id, vote: 1}))
      downvote_count: @voteDao.count((query) -> query.where({place_id, vote: -1}))
    .then (result) =>
      where = (query) -> query.where({place_id})
      @placeDao.modify where, (place) ->
        place.upvote_count = result.upvote_count
        place.downvote_count = result.downvote_count

provide.class(VoteService)
