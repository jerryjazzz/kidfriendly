
class Sector
  @table:
    name: 'sector'
    primary_key: 'sector_id'

  @fields:
    sector_id:
      type: 'id'
    lat:
      type: 'numeric'
    long:
      type: 'numeric'
    radius_meters:
      type: 'integer'
    google_search_at:
      type: 'timestamp'
    google_search_count:
      type: 'integer'
    factual_search_at:
      type: 'timestamp'
    factual_search_count:
      type: 'integer'

provide('dao/sector', -> depend('newDAO')(Sector))
