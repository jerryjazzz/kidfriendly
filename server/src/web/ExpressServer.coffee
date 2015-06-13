
fs = require('fs')
path = require('path')

class ExpressServer
  constructor: (@app, @expressConfig) ->
    @server = null
    @expressUtil = depend('ExpressUtil')

  start: ->
    if not @expressConfig.port?
      throw new Error("missing required express config: port")

    express = require('express')
    @server = express()

    @server.use(@add_stuff_to_request)

    # Middleware
    @server.use(require('express-domain-middleware'))
    @server.use(require('cookie-parser')())
    @server.use(require('body-parser').json())
    @server.use(require('passport').initialize())

    morgan = require('morgan')
    morgan.token('timestamp', (req, res) -> timestamp())
    logFormat = '[:timestamp] :method :url :status :res[content-length] - :response-time ms'
    @server.use(require('morgan')(logFormat))

    @server.use(@cors)

    # Routes
    staticFile = (filename) -> ((req,res) -> res.sendFile(path.resolve(filename)))
    staticDir = (dir) -> express.static(path.resolve(dir))
    redirect = (to) -> ((req,res) -> res.redirect(301, to))

    @server.get("/", staticFile('client/web/dist/index.html'))
    @server.get("/js/jquery.min.js", staticFile('server/node_modules/jquery/dist/jquery.min.js'))
    @server.get("/js/jquery.min.map", staticFile('server/node_modules/jquery/dist/jquery.min.map'))
    @server.get("/index.html", redirect('/'))
    @server.use(staticDir('client/web/dist'))
    @server.use("/mobile", staticDir('client/mobile/www'))
    @server.use("/dashboard", staticDir('client/dashboard'))

    @server.use('/admin', depend('AdminEndpoint').route)

    for path, obj of depend.multi('endpoint')
      @server.use(path, @expressUtil.routerFromObject(obj))

    port = @expressConfig.port

    if process.env.KFLY_DEV_SSL
      @app.log("launching Express server on port #{port} (using dev-mode SSL)")

      # Dev SSL mode. In prod, nginx handles SSL instead, and we use a real cert.
      https = require('https')
      options =
        key: fs.readFileSync('server/etc/self-signed-key.pem')
        cert: fs.readFileSync('server/etc/self-signed-cert.pem')
      https.createServer(options, @server).listen(port)

    else
      @app.log("launching Express server on port #{port}")
      @server.listen(port)

    return

  add_stuff_to_request: (req, res, next) =>
    req.get_ip = ->
      this.headers['x-real-ip'] or this.connection.remoteAddress

    res.sendRendered = (data) =>
      @expressUtil.renderResponse(req, res, data)

    next()

  cors: (req, res, next) =>
    res.set('Access-Control-Allow-Methods', 'GET,POST,OPTIONS')
    res.set('Access-Control-Allow-Headers', 'Content-Type')
    res.set('Access-Control-Allow-Origin', '*')
    #res.set('Access-Control-Expose-Headers', ...)
    next()

provide('ExpressServer', -> ExpressServer)
