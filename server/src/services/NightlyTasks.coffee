
class NightlyTasks
  constructor: ->
    CronJob = require('cron').CronJob
    @job = new CronJob("0 0 7 * * *", @run)
    @job.start()

  run: =>
    depend('FactualConsumer').refreshOldPlaceData()

provide('NightlyTasks', NightlyTasks)
