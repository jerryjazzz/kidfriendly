
class GooglePlace
  @table:
    name: 'google_place'

  @fields:
    place_id:
      type: 'id'
    lat:
      type: 'real'
    long:
      type: 'real'
    name:
      type: 'varchar(255)'
    google_place_id:
      type: 'varchar(40)'
    details_request_at:
      type: 'timestamp'
    details:
      type: 'json'

provide('dao/GooglePlace', -> depend('newDAO')(GooglePlace))
