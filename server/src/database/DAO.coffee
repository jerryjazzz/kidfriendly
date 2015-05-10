Promise = require('bluebird')

class DAO
  constructor: ({@modelClass}) ->
    @db = depend('db')
    @tableName = @modelClass.tableName
    @tableSchema  = depend('Configs').schema[@tableName]
    if not @tableSchema?
      throw new Error("no schema found for table: #{@tableName}")
    @idColumn = @tableSchema.primary_key
    @databaseUtil = depend('DatabaseUtil')

  find: (whereFunc) =>
    fieldNames = (k for k,v of @modelClass.fields)
    query = @db.select.apply(fieldNames).from(@tableName)
    whereFunc(query)
    query.then (rows) =>
      objects = for row in rows
        @modelClass.fromDatabase(row)
      objects

  findOne: (whereFunc) =>
    @find(whereFunc)
    .then (rows) ->
      rows[0]

  findById: (id) =>
    where = {}
    where[@idColumn] = id
    @find((query) -> query.where(where))
    .then (rows) ->
      rows[0]

  insert: (object) =>
    row = object.toDatabase()
    idColumn = @idColumn

    if not row.created_at? and @tableSchema.columns.created_at?
      row.created_at = timestamp()

    if not row.source_ver? and @tableSchema.columns.source_ver?
      row.source_ver = @sourceVersion

    # Check to auto-generate an ID. This involves some retry logic on the (unlikely)
    # chance that our random ID is taken.

    if not idColumn?
      # no ID column
      console.log('no id column')
      return @db(@tableName).insert(row).then(-> row)
    console.log('yes id column')

    if row[idColumn]?
      # new row already has an ID
      successResult = {}
      successResult[idColumn] = row[idColumn]
      return @db(@tableName).insert(row).then(-> successResult)

    new Promise (resolve, reject) =>
      attempt = (numAttempts) =>
        if numAttempts > 5
          return reject(msg: "failed to generate ID after 5 attempts")

        row[idColumn] = @databaseUtil.randomId()
        @db(@tableName).insert(row)
        .then ->
          object[idColumn] = row[idColumn]
          resolve(object)
        .catch @databaseUtil.existingKeyError(idColumn), (err) ->
          attempt(numAttempts + 1)
        .catch (otherErr) ->
          reject(otherErr)

      attempt(0)

  update: (object) =>
    console.log('update: ', object)
    if object.dataSource != 'local' or not object.original?
      throw new Error("DAO.update must be called on patch data: "+ object)

    where = {}
    where[@idColumn] = object[@idColumn]
    fields = object.toDatabase()
    @db(@tableName).update(fields).where(where)
    .then -> object
    
  update2: (whereFunc, object) =>
    if object.dataSource != 'local' or not object.original?
      throw new Error("DAO.update must be called on patch data: "+ object)

    fields = object.toDatabase()
    @db(@tableName).update(fields).where(whereFunc)
    .then -> object

  modify: (whereFunc, modifyFunc, {allowInsert} = {}) =>
    allowInsert = allowInsert ? false

    original = null

    @find(whereFunc).then (items) =>
      if items.length > 1
        return Promise.reject("DAO.modify: found multiple items, only supports 1 item")

      original = items[0]

      if not allowInsert and not original?
        return Promise.reject("DAO.modify: item not found")

      modified = if original?
        original.startPatch()
      else
        @modelClass.make()

      modifyFunc(modified)

      if original?
        @update2(whereFunc, modified).then -> modified
      else
        @insert(modified).then -> modified

  modifyOrInsert: (whereFunc, modifyFunc) ->
    @modify(whereFunc, modifyFunc, {allowInsert:true})

  modifyMulti: (whereFunc, modifyFunc) =>
    # Fetch a list of ids, then map them to @modify.

    modifyOne = (id) =>
      where = {}
      where[@idColumn] = id
      oneWhereFunc = (query) -> query.where(where)
      @modify(oneWhereFunc, modifyFunc)

    query = @db.select([@idColumn]).from(@tableName)
    whereFunc(query)
    query.then (results) =>
      for result in results
        result[@idColumn]
    .map(modifyOne, {concurrency: 1})

  @make: (args) ->
    new DAO(args)

provide('newDAO', -> DAO.make)
provide('UserDAO', -> new DAO(modelClass: depend('User')))
provide('ReviewDAO', -> new DAO(modelClass: depend('Review')))
provide('PlaceDAO', -> new DAO(modelClass: depend('Place')))
