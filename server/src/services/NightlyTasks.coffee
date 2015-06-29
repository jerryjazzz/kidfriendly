
ProdBudget =
  factualUpdate: 200
  googleCorrelationSearch: 200
  googleDetails: 400

ManualRunBudget =
  factualUpdate: 5
  googleCorrelationSearch: 2
  googleDetails: 2

class NightlyTasks
  constructor: ->
    CronJob = require('cron').CronJob
    @job = new CronJob("0 0 7 * * *", @run)
    @job.start()
    @FactualConsumer = depend('FactualConsumer')
    @GooglePlaces = depend('GooglePlaces')


  run: (budget) =>
    result = {}
    started_at = Date.now()
    if not budget?
      budget = ProdBudget

    Promise.resolve()
    .then =>
      @FactualConsumer.updatePlacesWithOldVersion(budget.factualUpdate)
      .then (places) ->
        result.factual_old_version_updates = places?.length
    .then =>
      @GooglePlaces.runCorrelationSearchJob(budget.googleCorrelationSearch)
    .then =>
      @GooglePlaces.runDetailsRequestJob(budget.googleDetails)
      .then (results) ->
        result.google_detail_requests = results?.length
    .then =>
      console.log("[NightlyTasks] finished in #{Date.now() - started_at}ms, results: #{JSON.stringify(result)}")
      result
    .catch (err) =>
      console.log("[NightlyTasks] error: #{err.message}\n#{err.stack}")

provide.class(NightlyTasks)

provide 'admin-endpoint/nightly', ->
  '/run-now': (req) ->
    depend('NightlyTasks').run(ManualRunBudget)
