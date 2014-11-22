
path = require('path')
Request = require('request')
Promise = require('bluebird')

class App

  constructor: (@config) ->
    @devMode = process.env.KFLY_DEV_MODE

    @appConfig = @config.appConfig

    # During startup we log to stdout, so that any problems are captured in Forever logs.
    # After startup is finished, we switch to the app log file.
    @log = console.log

    if @devMode
      @debugLog = console.log
    else
      @debugLog = ->

    @handlers = null
    @sourceVersion = null
    @currentGitCommit = null
    @sourceUtil = null
    @db = null
    @express = null
    @startedAt = Date.now()

    @logs = {}

    if @shouldWriteToLogFile()
      @logs.debug = new Log(this, "#{config.appName}.log")

    @inbox = null
    @pub = null

  start: ->
    Promise.resolve()
      #.then(@mysqlConnect)
      .then(@postgresConnect)
      .then(@sqlMigrate)
      .then(@initializeSourceVersion)
      .then(@setupInbox)
      .then(@setupPub)
      .then(@startExpress)
      .then(@startTaskManager)
      .then(@finishStartup)
      .catch (err) =>
        if err?.stack?
          @log(err?.stack)
        else
          @log(err)

  fetchCurrentGitVersion: =>
    SourceUtil.getCurrentGitCommit()
      .then (info) =>
        @currentGitCommit = info

  postgresConnect: =>
    {hostname, user, password} = @config.services.postgres

    userPrefix = ""
    if user?
      userPrefix = "#{user}:#{password}@"
    address = "postgres://#{userPrefix}#{hostname}/kidfriendly"
    @log("attempting to connect to: #{address}")

    PromiseUtil.retry (retry) =>
      @db = require('knex')({
        client: 'pg'
        connection: address
      })

      # connection test
      @db.raw('select 1')
        .catch Database.missingDatabaseError, =>
          @db.destroy()
          @db = null
          @createDatabase().then -> retry
    .then =>
      @log("postgres: connected")

  createDatabase: ->
    @log("creating database 'kidfriendly'")
    host = @config.services.postgres.hostname

    connection = require('knex')({
      client: 'pg'
      connection: "postgres://#{host}/postgres"
    })
    connection.raw('create database kidfriendly')
    .then =>
      connection.destroy()

  sqlMigrate: =>
    if @appConfig.roles?.dbMigration?
      migration = new SchemaMigration(this)
      migration.start()

  initializeSourceVersion: =>
    @sourceUtil = new SourceUtil(this)
    @sourceUtil.insertSourceVersion()
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

  shouldWriteToLogFile: ->
    return not @devMode

  finishStartup: =>
    duration = Date.now() - @startedAt
    @log("finished startup in #{duration} ms")

    if @shouldWriteToLogFile()
      @log("logs are now being written to: #{@logs.debug.filename}")
      @log = @_logToFile
      @log("finished startup in #{duration} ms")

  insert: (tableName, row) ->
    idColumn = @config.schema[tableName].primary_key

    if row[idColumn]?
      # new row already has an ID
      successResult = {}
      successResult[idColumn] = row[idColumn]
      return @db(tableName).insert(row).then(-> successResult)

    new Promise (resolve, reject) =>
      attempt = (numAttempts) =>
        if numAttempts > 5
          return reject(msg: "failed to generate ID after 5 attempts")

        row[idColumn] = Database.randomId()
        @db(tableName).insert(row)
        .then ->
          result = {}
          result[idColumn] = row[idColumn]
          resolve(result)
        .catch Database.existingKeyError(idColumn), (err) ->
          attempt(numAttempts + 1)
        .catch (otherErr) ->
          reject(otherErr)

      attempt(0)

  request: (args) ->
    @debugLog("url request: " + args.url)
    new Promise (resolve, reject) =>
      Request args, (error, message, body) =>
        if error?
          reject(error)
        else
          resolve(body)

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
