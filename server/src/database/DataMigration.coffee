
class DataMigration
  constructor: ->
    @placeDao = depend('dao/place')

  run: ->
    @initVotes()
    @initZipCode()

  initVotes: ->
    where = (query) ->
      query.whereNull('upvote_count').orWhereNull('downvote_count')

    @placeDao.modifyMulti where, (place) ->
      place.upvote_count = 0
      place.downvote_count = 0

  initZipCode: ->
    @placeDao.modifyMulti ((query)->query.whereNull('zipcode')), (place) ->
      console.log('upgraded place ', place.place_id)
      if place.details.zipcode?
        place.zipcode = place.details.postcode

provide.class(DataMigration)
