

class TestPlace
  id: 'testplace1'

  constructor: ->
    @placeDao = depend('dao/place')

  prepare: ->
    where = (query) => query.where(place_id: @id)
    @placeDao.modifyOrInsert where, (place) =>

      place.place_id = @id
      place.name = 'Test Place'
      place.rating = 70

      # somewhere in the pacific:
      place.lat = 30
      place.long = 171


provide.class(TestPlace)
