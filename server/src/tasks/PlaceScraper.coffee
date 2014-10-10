
class PlaceScraper
  apiKey: '***REMOVED***'

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

    radiusMiles = args[1]
    locations = LatLongUtil.latticePointsForAreaSimpler(area, radiusMiles)

    tasks = for location in locations
      {name: 'GooglePlaceSearch', location, radius:radiusMiles}
    console.log("created tasks: ", tasks)
    @taskManager.queueTasks(tasks)
    reply('ok')

  placeSearch: (task) ->
    console.log("Triggered placeSearch task..")
    setTimeout((-> console.log('Triggering placeSearch finish'); task.emit('finish')), 100)

  handleCommand: (args, reply) ->
    switch args[0]
      when 'start'
        startCommand(args.slice(1))
      else
        reply('unrecognized command')

exports.PlaceScraper = PlaceScraper
