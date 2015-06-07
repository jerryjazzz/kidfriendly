
class DataMigration
  constructor: ->
    @placeDao = depend('dao/place')

  run: ->

provide.class(DataMigration)
