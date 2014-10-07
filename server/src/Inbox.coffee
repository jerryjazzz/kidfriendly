
class Inbox
  constructor: (@server) ->
    @inbox = require('nanomsg').socket('rep')
    @inbox.bind(@server.config.services.web.inbox)
    @inbox.on 'message', @handleMessage
    @debug = @server.logs.debug

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

