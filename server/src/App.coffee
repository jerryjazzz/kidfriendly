
path = require('path')
Promise = require('bluebird')

class App

  constructor: (@config) ->

    @appConfig = @config.appConfig

    # During startup we log to stdout, so that any problems are captured in Forever logs.
    # After startup is finished, we switch to the app log file.
    @log = console.log

    if process.env.KFLY_DEV_MODE
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
      .then(@mysqlConnect)
      .then(@mysqlMigrate)
      .then(@redisConnect)
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

  mysqlMigrate: =>
    if @appConfig.roles?.dbMigration?
      migration = new SchemaMigration(this)
      migration.apply()

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
    return not process.env.KFLY_DEV_MODE

  finishStartup: =>
    duration = Date.now() - @startedAt
    @log("finished startup in #{duration} ms")

    if @shouldWriteToLogFile()
      @log("logs are now being written to: #{@logs.debug.filename}")
      @log = @_logToFile
      @log("finished startup in #{duration} ms")

  query: (sql, values = []) ->
    # query() wraps around mysql.query and turns it into a promise.

    isBadFieldError = (err) -> err.code == 'ER_BAD_FIELD_ERROR'

    sql = @db.format(sql, values)
    @debugLog('sql:', sql)

    new Promise (resolve, reject) =>
      @db.query sql, (err, result) ->
        if err?
          reject(err)
        else
          resolve(result)
    .catch isBadFieldError, (err) =>
      @log('SQL had bad_fied_error: ', sql)
      {error: 'SQL bad field error', sql: sql, statusCode: 500}

  sqlFormat: (sql, values = []) ->
    @db.format(sql, values)

  insert: (tableName, row) ->

    generatedId = false
    primaryKey = @config.schema[tableName].primary_key

    # Generate an ID if needed
    if primaryKey? and not row[primaryKey]?
      generatedId = true
      row[primaryKey] = Database.randomId()
      console.log('generated primary key for: ', primaryKey)

    attemptInsert = (retryCount) =>
      isDupeEntry = (err) -> err.code == 'ER_DUP_ENTRY' and retryCount < 5

      @query("insert into #{tableName} set ?", [row])
        .catch isDupeEntry, (err) =>

          # Check if this is a duplicated ID, or if the error was from something else.
          if generatedId
            @query("select 1 from #{tableName} where #{primaryKey} = ?", [row[primaryKey]]).then (response) ->
              if response.length == 0
                # The generated ID was fine, pass the original error back to the caller.
                return Promise.reject(err)

              # Generated ID was in use, retry with a different ID.
              row[primaryKey] = Database.randomId()
              attemptInsert(retryCount + 1)

    attemptInsert(0).then ->
      return {id: row.id}

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
