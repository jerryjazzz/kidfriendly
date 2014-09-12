
forever = require('forever-monitor')

listenStdout = (service, handler) ->
  service.on 'stdout', (data) ->
    handler(data.toString().trim())
  service.on 'stderr', (data) ->
    handler(data.toString().trim())

log = ->
  args = Array.prototype.slice.call(arguments, 0)
  console.log.apply(null, args)

web = new (forever.Monitor) '/kfly/server',
  cwd: '/kfly/server'
  command: 'node'
  silent: true
  options: []
  warn: log

web.on 'restart', ->
  log('Restarting web')

listenStdout web, (line) ->
  log("[web] #{line}")

web.start()
