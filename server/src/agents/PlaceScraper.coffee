
class PlaceScraper
  apiKey: '***REMOVED***'

  constructor: (@server) ->
    @redis = @server.redis
    @keyPrefix = 'agents.placeScraper'

  startCommand: (args, reply) ->
    areaName = args[1]
    area = LatLongUtil.areas[areaName]
    if not area?
      return reply('area not recognized: '+areaName)

    radiusMiles = args[2]
    locations = LatLongUtil.latticePointsForAreaSimpler(area, radiusMiles)
    
    @redis.rpush(@keyPrefix+'.locationsTodo', locations)
    reply('ok')

  handleCommand: (args, reply) ->
    switch args[0]
      when 'start'
        startCommand(args.slice(1))
      else
        reply('unrecognized command')

exports.PlaceScraper = PlaceScraper
