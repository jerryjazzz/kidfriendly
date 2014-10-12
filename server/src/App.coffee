
path = require('path')
Promise = require('bluebird')

class App

  constructor: (@config) ->
    @handlers = null
    @sourceVersion = null
    @currentGitCommit = null
    @db = null
    @express = null
    @startedAt = Date.now()

    @logs =
      debug: new Log("debug-#{config.appName}.log")

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
      .catch (err) ->
        console.log(err?.stack)

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
        console.log("mysql: connected")
        resolve()

  redisConnect: =>
    if not @config.appConfig.redis?
      console.log("redis: not started (config)")
      return

    new Promise (resolve, reject) =>
      @redis = require('redis').createClient()
      connected = false

      @redis.on 'ready', ->
        console.log("redis: connected")
        connected = true
        resolve()

      @redis.on 'error', (err) =>
        if not connected
          @redis.end()
          @redis = null
          reject(err)
          return

        console.log('redis err: ', err)
        @logs.debug.write(msg: 'Redis error', caused_by: err)

  initializeSourceVersion: =>
    Database.insertSourceVersion(this, @currentGitCommit)
      .then (id) =>
        @sourceVersion = id
        console.log("current source version is:", id)

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
    if not @config.appConfig.taskManager?
      return

    @taskManager = new TaskManager(this)
    @taskManager.start()

  finishStartup: =>
    console.log("finished startup in #{Date.now() - @startedAt} ms")

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
