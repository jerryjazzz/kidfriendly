
class ExpressServer
  constructor: (@app, @expressConfig) ->
    @server = null

  start: ->
    if not @expressConfig.port?
      throw new Error("missing required express config: port")

    express = require('express')
    @server = express()

    @server.use(@helpers)

    # Middleware
    @server.use(require('express-domain-middleware'))
    @server.use(require('cookie-parser')())
    @server.use(require('body-parser').json())

    morgan = require('morgan')
    morgan.token('timestamp', (req, res) -> DateUtil.timestamp())
    logFormat = '[:timestamp] :method :url :status :res[content-length] - :response-time ms'
    @server.use(require('morgan')(logFormat, {stream: @app.logs.debug}))

    @server.use(@cors)

    # Routes
    staticFile = (filename) -> ((req,res) -> res.sendFile(path.resolve(filename)))
    staticDir = (dir) -> express.static(path.resolve(dir))
    redirect = (to) -> ((req,res) -> res.redirect(301, to))

    @server.get("/", staticFile('client/web/dist/index.html'))
    @server.get("/index.html", redirect('/'))
    @server.use(staticDir('client/web/dist'))
    @server.use("/mobile", staticDir('client/mobile/www'))

    @server.use('/submit', (new SubmitEndpoint(@app)).endpoint)
    @server.use('/search', (new SearchEndpoint(@app)).endpoint)
    @server.use('/dev', (new DevEndpoint(@app)).endpoint)

    port = @expressConfig.port
    @app.log("launching Express server on port #{port}")
    @server.listen(port)
    return

  helpers: (req, res, next) =>
    req.get_ip = ->
      this.headers['x-real-ip'] or this.connection.remoteAddress

    next()

  cors: (req, res, next) =>
    res.set('Access-Control-Allow-Methods', 'GET,POST,OPTIONS')
    res.set('Access-Control-Allow-Headers', 'Content-Type')
    res.set('Access-Control-Allow-Origin', '*')
    #res.set('Access-Control-Expose-Headers', ...)
    next()
