
class GoogleNearbySearchAttempt
  @table:
    name: 'google_nearby_search_attempt'

  @fields:
    place_id:
      type: 'id'
    search_at:
      type: 'timestamp'

provide('dao/GoogleNearbySearchAttempt', -> depend('newDAO')(GoogleNearbySearchAttempt))
