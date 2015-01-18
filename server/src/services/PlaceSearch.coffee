
geolib = require('geolib')

class PlaceSearch
  constructor: ->
    @app = depend('App')

  search: (locationDistance) ->
    # locationDistance is {latitude, longitude, meters}
    query = @app.db.select('place_id','name','lat','long','details').from('place')

    bounds = GeomUtil.getBounds(locationDistance)

    # Filter to nearest rectangle
    query.orWhere('lat', '>', bounds.lat1)
    query.orWhere('lat', '<', bounds.lat2)
    query.orWhere('long', '>', bounds.long1)
    query.orWhere('long', '<', bounds.long2)

    # Future: Might want to add additional where clauses to query.
    
    query.then (results) =>
      results = @checkDistance(results, locationDistance)
      return results

  checkDistance: (places, locationDistance) ->
    # Store 'distance' on each result, and filter out places that are too far.

    for place in places
      place.distance = geolib.getDistance({latitude: place.lat, longitude: place.long},
          {latitude: locationDistance.lat, longitude: locationDistance.long})

    return places.filter (place) -> place.distance < locationDistance.meters

provide('PlaceSearch', PlaceSearch)
