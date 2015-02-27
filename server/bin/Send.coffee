
config = require('./../config')

findDestination = (name) ->
  appConfig = config.apps[name]
  if appConfig?
    if not appConfig.adminPort?
      throw new Error("App has no adminPort: "+name)
    return {adminPort: appConfig.adminPort}

  serviceConfig = config.services[name]
  if serviceConfig?
    if not serviceConfig.adminPort?
      throw new Error("Service has no adminPort: "+name)
    return {port: serviceConfig.adminPort}

  throw new Error("App or service not found: "+name)

send = (destinationName, msg, {andListen, log, ignoreError} = {}) ->
  {port} = findDestination(destinationName)

  if not log?
    log = console.log

  req = require('http').request
    host: '127.0.0.1'
    port: port
    method: 'POST'
    path: '/' + msg

  req.on 'error', (e) ->
    if not ignoreError
      console.log(e)

  req.on 'response', (res) ->
    res.setEncoding('utf8')
    res.on 'data', (data) ->
      log(data)

  req.end()

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
