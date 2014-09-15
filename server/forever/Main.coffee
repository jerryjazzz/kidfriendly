
forever = require('forever-monitor')
config = require('./../config')

process.chdir(__dirname)

listenStdout = (service, handler) ->
  service.on 'stdout', (data) ->
    handler(data.toString().trim())
  service.on 'stderr', (data) ->
    handler(data.toString().trim())

log = ->
  args = Array.prototype.slice.call(arguments, 0)
  console.log.apply(null, args)

web = new (forever.Monitor) '..',
  command: 'node'
  silent: true
  options: []
  warn: log

web.on 'restart', ->
  log('Restarting web')

listenStdout web, (line) ->
  log("[web] #{line}")

web.start()

shutdown = ->
  log("Shutting down..")
  web.kill(true)
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
      web.restart()
      inbox.send('ok')
    when 'simulate_exception'
      throw new Error('simulated_exception')
    else
      inbox.send('command not recognized')
