
class Inbox
  constructor: (@app, address) ->
    @commandHandlers = {}
    @socket = require('nanomsg').socket('rep')
    @socket.bind(address)
    @socket.on 'message', @handleMessage

  registerCommand: (name, handler) ->
    if @commandHandlers[name]?
      throw new Error("command already registered: "+name)
    @commandHandlers[name] = handler

  handleMessage: (buf) =>
    msg = buf.toString()
    args = msg.split(' ')
    command = args[0]
    handler = @commandHandlers[command]

    replySent = false

    reply = (msg) =>
      if replySent
        throw new Error("reply() was already sent")

      if not typeof msg is 'string'
        msg = JSON.stringify(msg)

      @socket.send(msg)
      replySent = true

    if not handler?
      reply("unrecognized command: "+command)
      return

    try
      handler(args.slice(1), reply)
    catch e
      console.log(e.stack)

    # Reply must be sent synchronously (this is a restriction of nanomsg)
    if not replySent
      reply("handler failed to send a reply")

  @setup: (app) ->
    appConfig = app.config.appConfig
    if not appConfig.inbox?
      console.log("nanomsg inbox: not started (config)")
      return

    app.inbox = new Inbox(app, appConfig.inbox)
    console.log("nanomsg inbox: listening on "+appConfig.inbox)
    return
