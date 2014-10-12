
config = require('./../config')
nano = require('nanomsg')

findDestination = (name) ->
  appConfig = config.apps[name]
  if appConfig?
    if not appConfig.inbox?
      throw new Error("App has no inbox: "+name)
    return {inbox: appConfig.inbox, pub: appConfig.pub}

  serviceConfig = config.services[name]
  if serviceConfig?
    if not serviceConfig.inbox?
      throw new Error("Service has no inbox: "+name)
    return {inbox: serviceConfig.inbox, pub: serviceConfig.pub}

  throw new Error("App or service not found: "+name)

send = (destinationName, msg, {andListen, log, ignoreError} = {}) ->
  {inbox, pub} = findDestination(destinationName)

  if not log?
    log = console.log

  if andListen
    if not pub?
      throw new Error("Destination has no pub channel: "+destinationName)

    subSocket = nano.socket('sub')
    subSocket.connect(pub)
    subSocket.on 'message', (buf) ->
      log('[pub]   ' + buf.toString())

  socket = nano.socket('req')
  socket.connect(inbox)
  socket.send(msg)

  timeout = null

  socket.on 'message', (buf) ->
    line = buf.toString()
    if andListen
      line = '[reply] ' +line
    log(line)

    socket.close()
    socket = null

    #if timeout?
      # todo: cancel timeout

  socket.on 'error', (err) ->
    socket.close()
    socket = null
    throw err

  timeoutMs = 1000

  timeout = setTimeout((->
    if socket?
      if not ignoreError
        log("Timed out waiting for a reply (#{timeoutMs}ms)")
    ), timeoutMs)

main = ->
  args = process.argv.slice(2)

  andListen = false
  if args[0] == '--and-listen'
    andListen = true
    args = args.slice(1)

  send(args[0], args.slice(1).join(' '), {andListen})
  

if require.main == module
  main()

module.exports = {send,main}
