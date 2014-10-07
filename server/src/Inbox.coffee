
class Inbox
  constructor: (@app) ->
    appConfig = @app.config.appConfig
    if not appConfig.inbox?
      console.log("nanomsg inbox: not started (config)")
      return

    @inbox = require('nanomsg').socket('rep')
    @inbox.bind(appConfig.inbox)
    @inbox.on 'message', @handleMessage
    @debug = @app.logs.debug
    console.log("nanomsg inbox: listening on "+appConfig.inbox)

  handleMessage: (buf) =>
    msg = buf.toString()

    @debug.write(msg: "Received message: "+msg)

    args = msg.split(' ')

    try
      switch args[0]
        when 'scrape-start'
          @inbox.send('todo')
        when 'scrape-status'
          @inbox.send('todo')
        else
          @inbox.send("unrecognized command: " + args[0])
    
    catch e
      @inbox.send(e.stack)

