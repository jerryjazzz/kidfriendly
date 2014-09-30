
path = require('path')
Promise = require('bluebird')


class Server

  constructor: (@config) ->
    @handlers = null
    @sourceVersion = null
    @currentGitCommit = null
    @db = null
    @agents = {}

    @logs =
      emailSignup: new Log(config, 'email_signup.json')
      surveyAnswer: new Log(config, 'survey_answer.json')
      debug: new Log(config, 'debug.log')

    @inbox = new Inbox(this)

  start: ->
    @fetchCurrentGitVersion()
      .then(@startMysql)
      #.then(@startRedis)
      .then(@initializeSourceVersion)
      .then(@startAgents)
      .then(@startExpress)
      .catch (err) ->
        console.log(err.stack)

  fetchCurrentGitVersion: =>
    SourceUtil.getCurrentGitCommit()
      .then (info) =>
        console.log("Current git commit:", info)
        @currentGitCommit = info

  startMysql: =>
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

  startRedis: =>
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

  startAgents: =>
    new Promise (resolve, reject) =>
      @agents.placeScraper = new PlaceScraper(this)
      resolve()

  startExpress: =>
    express = require('express')
    @app = express()

    @app.use(@helpers)

    # Middleware
    @app.use(require('express-domain-middleware'))
    @app.use(require('cookie-parser')())
    @app.use(require('body-parser').json())

    morgan = require('morgan')
    morgan.token('timestamp', (req, res) -> DateUtil.timestamp())
    logFormat = '[:timestamp] :method :url :status :res[content-length] - :response-time ms'
    @app.use(require('morgan')(logFormat, {stream: @logs.debug}))

    @app.use(@cors)

    # Routes
    staticFile = (filename) -> ((req,res) -> res.sendFile(path.resolve(filename)))
    staticDir = (dir) -> express.static(path.resolve(dir))
    redirect = (to) -> ((req,res) -> res.redirect(301, to))

    @app.get("/", staticFile('web/dist/index.html'))
    @app.get("/index.html", redirect('/'))
    @app.use(staticDir('web/dist'))

    @handlers =
      submit: new SubmitEndpoint(this)

    port = 3000
    console.log("Launching server on port #{port}")
    @app.listen(port)

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

startup = ->
  # Change directory to top-level, one above the 'server' dir. (such as /kfly)
  dir = path.resolve(path.join(__dirname, '../..'))

  console.log('Changing current dir to: ' + dir)
  process.chdir(dir)

  config = require('./../config')
  
  server = new Server(config)
  server.start()

exports.startup = startup
