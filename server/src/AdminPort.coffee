
class AdminPort
  constructor: (port, onCommand) ->
    @server = require('http').createServer()
    @server.listen(port)

  onMessage: (handler) ->
    @server.on 'request', (req,res) ->
      console.log('request: ' + req.url)
      commandResponse = handler(req.url.slice(1))
      res.write(commandResponse)
      res.end()

exports.AdminPort = AdminPort
if provide?
  provide('AdminPort', -> AdminPort)
