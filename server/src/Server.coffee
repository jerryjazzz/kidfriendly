
path = require('path')
Promise = require('bluebird')


class Server

  constructor: (@config) ->
    @handlers = null
    @sourceVersion = null
    @currentGitCommit = null
    @logs =
      emailSignup: new Log(config, 'email_signup')

  start: ->
    @fetchCurrentGitVersion()
      .then(@startMysql)
      .then(@initializeSourceVersion)
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
        else
          console.log("Connected to Mysql")
          resolve()

  initializeSourceVersion: =>
    Database.insertSourceVersion(this, @currentGitCommit)
      .then (id) =>
        @sourceVersion = id
        console.log("Source version id is:", id)

  startExpress: =>
    express = require('express')
    @app = express()

    @app.use (req, res, next) ->
      req.get_ip = ->
        this.headers['x-real-ip'] or this.connection.remoteAddress
      next()

    # Middleware
    @app.use(require('express-domain-middleware'))
    @app.use(require('cookie-parser')())
    @app.use(require('body-parser').json())

    @app.use(require('morgan')('[:date] :method :url :status :res[content-length] - :response-time ms'))

    @app.use(@cors)

    # Routes
    staticFile = (filename) -> ((req,res) -> res.sendFile(path.resolve(filename)))
    staticDir = (dir) -> express.static(path.resolve(dir))
    redirect = (to) -> ((req,res) -> res.redirect(301, to))

    @app.get("/", staticFile('web/dist/index.html'))
    @app.get("/index.html", redirect('/'))
    @app.use(staticDir('web/dist'))

    @handlers =
      emailSignup: new EmailSignup(this)

    port = 3000
    console.log("Launching server on port #{port}")
    @app.listen(port)

  cors: (req, res, next) =>
    res.set('Access-Control-Allow-Methods', 'GET,POST,OPTIONS')
    res.set('Access-Control-Allow-Headers', 'Content-Type')
    res.set('Access-Control-Allow-Origin', '*')
    next()
    #res.set('Access-Control-Expose-Headers', ...)

startup = ->
  # Change directory to top-level, one above the 'server' dir. (such as /kfly)
  dir = path.resolve(path.join(__dirname, '../..'))

  console.log('Changing current dir to: ' + dir)
  process.chdir(dir)

  config = require('./../config')
  
  server = new Server(config)
  server.start()

exports.startup = startup
