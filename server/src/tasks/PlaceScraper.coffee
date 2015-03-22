
class PlaceScraper
  apiKey: '***REMOVED***'
  nearbySearchUrl: 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'

  constructor: (@app, @taskManager) ->
    @redis = @app.redis
    @keyPrefix = 'agents.placeScraper'

    @app.inbox.registerCommand 'start-scrape', @startScrape
    @taskManager.register 'GooglePlaceSearch', @placeSearch

  startScrape: (args, reply) =>
    areaName = args[0]
    area = LatLongUtil.areas[areaName]
    if not area?
      return reply('area not recognized: '+areaName)

    radiusMiles = parseFloat(args[1])
    locations = LatLongUtil.latticePointsForAreaSimpler(area, radiusMiles)

    tasks = for location in locations
      {name: 'GooglePlaceSearch', location, radius:radiusMiles}

    @taskManager.queueTasks(tasks)
    reply('ok')

  placeSearch: (task) =>
    url = @nearbySearchUrl
    url += "?key=#{@apiKey}"
    url += "&location=#{task.location.lat},#{task.location.long}"

    radiusMeters = GeomUtil.milesToMeters(task.radius)
    url += "&radius=#{radiusMeters}"

    request = require('request')
    request {url, json:true}, (error, response, body) =>
      if error?
        @app.log('nearby search failed: ', error)
        return

      for place in body.results
        @savePlaceToMysql(place)
      task.emit('done')

  savePlaceToMysql: (googlePlace) =>
    row =
      name: googlePlace.name
      location: "#{googlePlace.geometry.location.lat},#{googlePlace.geometry.location.lng}"
      google_id: googlePlace.id
      created_at: timestamp()
      source_ver: @app.sourceVersion

    Database.writeRow(@app, 'place', row, {generateId: true})
      .then (result) =>
        if result.error?
          @app.log(msg: "error saving google place to DB", google_id: googlePlace.id, \
            caused_by: result.error)

exports.PlaceScraper = PlaceScraper
