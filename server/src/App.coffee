
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
    @databaseUtil = depend('DatabaseUtil')

    @logs = {}

    if @shouldWriteToLogFile()
      Log = depend('Log')
      @logs.debug = new Log(this, "#{config.appName}.log")

    @adminPort = null

  start: ->
    Promise.resolve()
      .then(@postgresConnect)
      .then(@sqlMigrate)
      .then(@initializeSourceVersion)
      .then(@setupAdminPort)
      .then(@setupPub)
      .then(@startExpress)
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

  getKnexOptions: =>
    client: 'pg'
    debug: @config.services.postgres.debugConnection
    connection:
      user: process._successfulSetuidUser
      host: @config.services.postgres.host
      database: @config.services.postgres.database

  postgresConnect: =>

    depend('PromiseUtil').retry (retry) =>
      @db = require('knex')(@getKnexOptions())

      # connection test
      @db.raw('select 1')
        .catch @databaseUtil.missingDatabaseError, =>

          # Create database and retry
          @db.destroy()
          @db = null
          @createDatabase().then -> retry
          
    .then =>
      @log("postgres connected")
    .catch (e) =>
      @log("[ERROR] postgres connection: " + e)
      @db = null

  createDatabase: ->
    @log("creating database 'kidfriendly'")
    host = @config.services.postgres.hostname

    knexOptions = @getKnexOptions()
    knexOptions.connection.database = 'postgres'

    connection = require('knex')(knexOptions)
    connection.raw('create database kidfriendly')
    .then =>
      connection.destroy()

  sqlMigrate: =>
    if @appConfig.roles?.dbMigration?

      if not @db?
        @log("skipping migration (no DB)")
        return

      SchemaMigration = depend('SchemaMigration')
      migration = new SchemaMigration(this)
      migration.start()

  initializeSourceVersion: =>
    if not @db?
      @log("skipping source version init (no DB)")
      return

    @sourceUtil = depend('SourceUtil')
    @sourceUtil.insertSourceVersion()
      .then (id) =>
        @sourceVersion = id
        @log("current source version is:", id)

  setupAdminPort: =>
    @log("listening on admin port: " + @config.appConfig.adminPort)
    AdminPort = depend('AdminPort')
    @adminPort = AdminPort(@config.appConfig.adminPort)

  startExpress: =>
    if not @config.appConfig.express?
      return

    ExpressServer = depend('ExpressServer')
    @expressServer = new ExpressServer(this, @config.appConfig.express)
    @expressServer.start()

  shouldWriteToLogFile: ->
    return not @devMode

  finishStartup: =>
    depend('NightlyTasks')

    duration = Date.now() - @startedAt
    @log("Server startup completed (in #{duration} ms)")

    if @shouldWriteToLogFile()
      @log("logs are now being written to: #{@logs.debug.filename}")
      @log = @_logToFile
      @log("Server startup completed (in #{duration} ms)")

  insert: (tableName, row) ->
    tableSchema = @config.schema[tableName]
    idColumn = tableSchema.primary_key

    if not row.created_at? and tableSchema.columns.created_at?
      row.created_at = timestamp()

    if not row.source_ver? and tableSchema.columns.source_ver?
      row.source_ver = @sourceVersion

    # Check to auto-generate an ID. This involves some retry logic on the (unlikely)
    # chance that our random ID is taken.

    if not idColumn?
      # no ID column
      return @db(tableName).insert(row).then(-> row)

    if row[idColumn]?
      # new row already has an ID
      successResult = {}
      successResult[idColumn] = row[idColumn]
      return @db(tableName).insert(row).then(-> successResult)

    new Promise (resolve, reject) =>
      attempt = (numAttempts) =>
        if numAttempts > 5
          return reject(msg: "failed to generate ID after 5 attempts")

        row[idColumn] = @databaseUtil.randomId()
        @db(tableName).insert(row)
        .then ->
          result = {}
          result[idColumn] = row[idColumn]
          resolve(result)
        .catch @databaseUtil.existingKeyError(idColumn), (err) ->
          attempt(numAttempts + 1)
        .catch (otherErr) ->
          reject(otherErr)

      attempt(0)

  request: (args) ->
    @debugLog("url request: " + args.url)
    args.json = args.json ? true
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

    @logs.debug.write("[#{timestamp()}] #{args.join(' ')}")

startApp = (appName = 'web') ->
  console.log('Launching app: '+appName)

  try
    # Try to setuid() to a user matching the app name. Only expected to work when running
    # on server.
    user = appName
    process.setuid(user)
    console.log("setuid() successful with: "+user)
    process._successfulSetuidUser = user

  # Change directory to top-level, one above the 'server' dir. (such as /kfly)
  dir = path.resolve(path.join(__dirname, '../..'))

  process.chdir(dir)
  console.log('current directory is now: ' + dir)

  config = require('./../config')

  if not config.apps[appName]?
    throw new Error("service name not found in config: "+appName)

  config.appName = appName
  config.appConfig = config.apps[appName]

  app = new App(config)
  provide('App', -> app)
  app.start()

exports.startApp = startApp
