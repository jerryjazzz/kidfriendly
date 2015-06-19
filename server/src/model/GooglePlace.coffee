
class GooglePlace
  @table:
    name: 'google_place'
    primary_key: 'place_id'

  @fields:
    place_id:
      type: 'id'
    google_place_id:
      type: 'varchar(40)'
    details_request_at:
      type: 'timestamp'
    details:
      type: 'json'

provide('dao/GooglePlace', -> depend('newDAO')(GooglePlace))
