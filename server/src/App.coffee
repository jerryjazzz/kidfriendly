
path = require('path')
Promise = require('bluebird')

class App

  constructor: (@config) ->
    @handlers = null
    @sourceVersion = null
    @currentGitCommit = null
    @db = null
    @express = null

    @logs =
      debug: new Log("debug-#{config.appName}.log")

    @inbox = new Inbox(this)

  start: ->
    @fetchCurrentGitVersion()
      .then(@mysqlConnect)
      #.then(@redisConnect)
      .then(@initializeSourceVersion)
      .then(@startExpress)
      .then(@finishStartup)
      .catch (err) ->
        console.log(err.stack)

  fetchCurrentGitVersion: =>
    SourceUtil.getCurrentGitCommit()
      .then (info) =>
        console.log("Current git commit:", info)
        @currentGitCommit = info

  mysqlConnect: =>
    mysql = require('mysql')
    new Promise (resolve, reject) =>
      @db = mysql.createConnection
        host: 'localhost'
        user: 'web'
        database: 'kidfriendly'
        multipleStatements: true

      @db.connect (err, conn) =>
        if err?
          console.log("[error] from db.connect: ", err)
          reject(err)
          return
        console.log("Connected to Mysql")
        resolve()

  redisConnect: =>
    new Promise (resolve, reject) =>
      @redis = require('redis').createClient()
      @redis.on 'error', (err) =>
        @logs.debug(msg: 'Redis error', caused_by: err)
      resolve()

  initializeSourceVersion: =>
    Database.insertSourceVersion(this, @currentGitCommit)
      .then (id) =>
        @sourceVersion = id
        console.log("Source version id is:", id)

  startExpress: =>
    if not @config.appConfig.express?
      return

    if not @config.appConfig.express.port?
      throw new Error("missing required express config: port")

    expressLib = require('express')
    @express = expressLib()

    @express.use(@expressHelpers)

    # Middleware
    @express.use(require('express-domain-middleware'))
    @express.use(require('cookie-parser')())
    @express.use(require('body-parser').json())

    morgan = require('morgan')
    morgan.token('timestamp', (req, res) -> DateUtil.timestamp())
    logFormat = '[:timestamp] :method :url :status :res[content-length] - :response-time ms'
    @express.use(require('morgan')(logFormat, {stream: @logs.debug}))

    @express.use(@cors)

    # Routes
    staticFile = (filename) -> ((req,res) -> res.sendFile(path.resolve(filename)))
    staticDir = (dir) -> expressLib.static(path.resolve(dir))
    redirect = (to) -> ((req,res) -> res.redirect(301, to))

    @express.get("/", staticFile('web/dist/index.html'))
    @express.get("/index.html", redirect('/'))
    @express.use(staticDir('web/dist'))

    @handlers =
      submit: new SubmitEndpoint(this)

    port = @config.appConfig.express.port
    console.log("launching Express server on port #{port}")
    @express.listen(port)
    return

  expressHelpers: (req, res, next) =>
    req.get_ip = ->
      this.headers['x-real-ip'] or this.connection.remoteAddress

    next()

  cors: (req, res, next) =>
    res.set('Access-Control-Allow-Methods', 'GET,POST,OPTIONS')
    res.set('Access-Control-Allow-Headers', 'Content-Type')
    res.set('Access-Control-Allow-Origin', '*')
    #res.set('Access-Control-Expose-Headers', ...)
    next()

  finishStartup: =>
    console.log("finished starting up")

startApp = (appName = 'web') ->
  console.log('launching app: '+appName)

  # Change directory to top-level, one above the 'server' dir. (such as /kfly)
  dir = path.resolve(path.join(__dirname, '../..'))

  console.log('changing current dir to: ' + dir)
  process.chdir(dir)

  config = require('./../config')

  if not config.apps[appName]?
    throw new Error("service name not found in config: "+appName)

  config.appName = appName
  config.appConfig = config.apps[appName]

  app = new App(config)
  app.start()

exports.startApp = startApp
