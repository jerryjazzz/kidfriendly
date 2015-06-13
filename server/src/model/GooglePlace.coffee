
class GooglePlace
  @table:
    name: 'google_place'

  @fields:
    place_id:
      type: 'id'
    google_place_id:
      type: 'id'

provide('dao/GooglePlace', -> depend('newDAO')(GooglePlace))
