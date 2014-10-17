
path = require('path')
Promise = require('bluebird')

class App

  constructor: (@config) ->

    # During startup we log to stdout, so that any problems are captured in Forever logs.
    # After startup is finished, we switch to the app log file.
    @log = console.log

    @handlers = null
    @sourceVersion = null
    @currentGitCommit = null
    @db = null
    @express = null
    @startedAt = Date.now()

    @logs =
      debug: new Log(this, "#{config.appName}.log")

    console.log('opened logfile: ', config.appName)

    @inbox = null
    @pub = null


  start: ->
    @fetchCurrentGitVersion()
      .then(@mysqlConnect)
      .then(@redisConnect)
      .then(@initializeSourceVersion)
      .then(@setupInbox)
      .then(@setupPub)
      .then(@startExpress)
      .then(@startTaskManager)
      .then(@finishStartup)
      .catch (err) =>
        @log(err?.stack)

  fetchCurrentGitVersion: =>
    SourceUtil.getCurrentGitCommit()
      .then (info) =>
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
          reject(err)
          return
        @log("mysql: connected")
        resolve()

  redisConnect: =>
    if not @config.appConfig.redis?
      @log("redis: not started (config)")
      return

    new Promise (resolve, reject) =>
      @redis = require('redis').createClient()
      connected = false

      @redis.on 'ready', =>
        @log("redis: connected")
        connected = true
        resolve()

      @redis.on 'error', (err) =>
        if not connected
          @redis.end()
          @redis = null
          reject(err)
          return

        @log('redis error: ', err)

  initializeSourceVersion: =>
    Database.insertSourceVersion(this, @currentGitCommit)
      .then (id) =>
        @sourceVersion = id
        @log("current source version is:", id)

  setupInbox: =>
    Inbox.setup(this)

  setupPub: =>
    PubChannel.setup(this)

  startExpress: =>
    if not @config.appConfig.express?
      return

    @expressServer = new ExpressServer(this, @config.appConfig.express)
    @expressServer.start()

  startTaskManager: =>
    if not @config.appConfig.taskRunner?
      return

    @taskRunner = new TaskRunner(this)
    @taskRunner.start()

  finishStartup: =>
    msg = "finished startup in #{Date.now() - @startedAt} ms"
    @log(msg)
    @log = @_logToFile
    @log(msg)

  _logToFile: =>
    args = for arg in arguments
      if typeof arg is 'string'
        arg
      else
        JSON.stringify(arg)

    @logs.debug.write("[#{DateUtil.timestamp()}] #{args.join(' ')}")

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
