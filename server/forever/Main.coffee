
forever = require('forever-monitor')
config = require('./../config')
{AdminPort} = require('./../src/AdminPort')

process.chdir(__dirname+'/../..')

log = ->
  args = Array.prototype.slice.call(arguments, 0)
  console.log.apply(null, args)

startApp = (appName) ->
  appConfig = config.apps[appName]

  foreverOptions =
    command: 'node'
    silent: true
    warn: log

  if appConfig.foreverOptions?
    for k,v of appConfig.foreverOptions
      foreverOptions[k] = v

  mainScript = appConfig.main or 'server'

  app = new (forever.Monitor)(mainScript, foreverOptions)

  app.on 'restart', ->
    log("[forever] Restarting "+ appName)

  app.on 'stdout', (data) ->
    log("[#{appName}] #{data.toString().trim()}")
  app.on 'stderr', (data) ->
    log("[#{appName}] #{data.toString().trim()}")

  app.start()
  return app

args = process.argv.slice(2)
appNames = []

if args.length > 0
  appNames = args
  console.log("[forever] Launching apps (command args): "+appNames)
else
  # default is to launch all apps in config.
  appNames = Object.keys(config.apps)
  console.log("[forever] Launching apps (default): "+appNames)

apps = for appName in appNames
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
adminPort = config.services.forever.adminPort
console.log('[forever] listening on admin port: ' + adminPort)
adminServer = new AdminPort(adminPort)
adminServer.onMessage (message) ->
  log('[forever] Received message: '+ message)
  switch message
    when 'restart'
      for app in apps
        app.restart()
      return 'ok'
    else
      return 'command not recognized: ' + message
