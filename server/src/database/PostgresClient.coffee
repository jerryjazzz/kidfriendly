
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

    knexOptions = @getKnexOptions()

    depend('PromiseUtil').retry (retry) =>
      @knex = require('knex')(knexOptions)

      # connection test
      @knex.raw('select 1')
        .catch @databaseUtil.missingDatabaseError, =>

          # Create database and retry
          @knex.destroy()
          @knex = null
          @createDatabase().then -> retry
          
    .then =>
      @app.log("postgres connected to: " + knexOptions.connection.database)

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

  sqlMigrate: ->
    if not @knex?
      @log("skipping migration (no DB)")
      return

    depend('SchemaMigration').start()


provide.class(PostgresClient)
provide('db', -> depend('PostgresClient').knex)
