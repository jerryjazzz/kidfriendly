
class NightlyTasks
  constructor: ->
    CronJob = require('cron').CronJob
    @job = new CronJob("0 0 7 * * *", @run)
    @job.start()
    @FactualConsumer = depend('FactualConsumer')
    @GooglePlaces = depend('GooglePlaces')

  run: =>
    result = {}

    Promise.resolve()
    .then =>
      @FactualConsumer.updatePlacesWithOldVersion(200)
      .then (places) ->
        result.factual_old_version_updates = places?.length
    .then =>
      @FactualConsumer.runSectorSearches(200)
      .then (sectors) ->
        result.factual_sector_searches = sectors?.length
    .then =>
      @GooglePlaces.runSectorSearchJob(200)
      .then (sectors) ->
        result.google_sector_searches = sectors?.length
    .then =>
      @GooglePlaces.runDetailsRequestJob(200)
      .then (results) ->
        result.google_detail_requests = results?.length
    .then =>
      console.log("[NightlyTasks] finished: #{JSON.stringify(result)}")
      result
    .catch (err) =>
      console.log("[NightlyTasks] error: #{err.message}\n#{err.stack}")

provide.class(NightlyTasks)

provide 'admin-endpoint/nightly', ->
  '/run-now': (req) ->
    depend('NightlyTasks').run()
