
Promise = require('bluebird')

class PostgresClient
  constructor: ->
    @knex = null
    @app = depend('App')
    @config = depend('Configs')
    @databaseUtil = depend('DatabaseUtil')

  getKnexOptions: =>
    client: 'pg'
    debug: @config.services.postgres.debugConnection
    connection:
      user: process._successfulSetuidUser
      host: @config.services.postgres.host
      database: @config.services.postgres.database

  connect: =>

    depend('PromiseUtil').retry (retry) =>
      @knex = require('knex')(@getKnexOptions())

      # connection test
      @knex.raw('select 1')
        .catch @databaseUtil.missingDatabaseError, =>

          # Create database and retry
          @knex.destroy()
          @knex = null
          @createDatabase().then -> retry
          
    .then =>
      @app.log("postgres connected")
    .catch (e) =>
      @app.log("[ERROR] postgres connection: " + e)
      @knex = null

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

      if not @knex?
        @log("skipping migration (no DB)")
        return

      SchemaMigration = depend('SchemaMigration')
      migration = new SchemaMigration(this)
      migration.start()

  insert: (tableName, row) =>
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
      return @knex(tableName).insert(row).then(-> row)

    if row[idColumn]?
      # new row already has an ID
      successResult = {}
      successResult[idColumn] = row[idColumn]
      return @knex(tableName).insert(row).then(-> successResult)

    new Promise (resolve, reject) =>
      attempt = (numAttempts) =>
        if numAttempts > 5
          return reject(msg: "failed to generate ID after 5 attempts")

        row[idColumn] = @databaseUtil.randomId()
        @knex(tableName).insert(row)
        .then ->
          result = {}
          result[idColumn] = row[idColumn]
          resolve(result)
        .catch @databaseUtil.existingKeyError(idColumn), (err) ->
          attempt(numAttempts + 1)
        .catch (otherErr) ->
          reject(otherErr)

      attempt(0)

provide('PostgresClient', PostgresClient)
