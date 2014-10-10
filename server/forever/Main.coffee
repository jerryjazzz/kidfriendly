
forever = require('forever-monitor')
config = require('./../config')

process.chdir(__dirname+'/../..')

log = ->
  args = Array.prototype.slice.call(arguments, 0)
  console.log.apply(null, args)

startApp = (appName) ->
  app = new (forever.Monitor) 'server',
    command: 'node'
    silent: true
    options: [appName]
    warn: log

  app.on 'restart', ->
    log("[forever] Restarting "+ appName)

  app.on 'stdout', (data) ->
    log("[#{appName}] #{data.toString().trim())
  app.on 'stderr', (data) ->
    log("[#{appName}] #{data.toString().trim())

  app.start()
  return app

apps = for appName, appConfig in config.apps
  startApp(appName)

shutdown = ->
  log("Shutting down..")
  for app in apps
    app.kill(true)
  setTimeout((-> process.exit(0)), 500)

process.on 'shutdown', shutdown
process.on 'uncaughtException', (e) ->
  console.log(e.stack)
  shutdown()

# Listen for 'restart' messages
inbox = require('nanomsg').socket('rep')
inbox.bind(config.services.forever.inbox)
inbox.on 'message', (buf) ->
  msg = buf.toString()
  log('received message: '+ msg)
  switch msg
    when 'restart'
      for app in apps
        app.restart()
      inbox.send('ok')
    when 'simulate_exception'
      throw new Error('simulated_exception')
    else
      inbox.send('command not recognized')

