Promise = require('bluebird')

class DAO
  constructor: ({@modelClass}) ->
    @db = depend('db')
    if not @modelClass.table?
      throw new Error("missing .table for #{@modelClass.name}")
    @tableName = @modelClass.tableName ? @modelClass.table.name
    @tableSchema  = depend('Configs').schema[@tableName]
    if not @tableSchema?
      throw new Error("no schema found for table: #{@tableName}")
    @idColumn = @tableSchema.primary_key ? @modelClass.table.primary_key
    @databaseUtil = depend('DatabaseUtil')

  newInstance: ->
    if @modelClass.make?
      @modelClass.make()
    else
      obj = new (@modelClass)()
      obj.dataSource = 'local'
      obj

  instanceFromDatabase: (row) ->
    if @modelClass.fromDatabase?
      return @modelClass.fromDatabase(row)

    object = new (@modelClass)()
    object.dataSource = 'db'
    for k,v of row
      object[k] = v
    object

  patchInstance: (original) ->
    if original.dataSource != 'db'
      throw Error("Place.startPatch can only be called on original DB data")

    patch = Object.create(original)
    patch.original = original
    patch.dataSource = 'local'
    return patch

  find: (whereFunc) =>
    fieldNames = (k for k,v of @modelClass.fields)
    query = @db.select.apply(fieldNames).from(@tableName)

    if typeof whereFunc == 'function'
      whereFunc(query)
    else
      query.where(whereFunc)

    query.then (rows) =>
      @instanceFromDatabase(row) for row in rows

  findOne: (whereFunc) =>
    @find(whereFunc)
    .then (rows) ->
      rows[0]

  findById: (id) =>
    if not id? or id == ''
      throw new Error('id is required')

    where = {}
    where[@idColumn] = id
    @find((query) -> query.where(where))
    .then (rows) ->
      rows[0]

  count: (whereFunc) =>
    query = @db(@tableName).count('*')
    whereFunc(query)
    query.then (result) ->
      parseInt(result[0].count)

  objectToDatabase: (object) ->
    if object.toDatabase?
      return object.toDatabase()

    fields = {}
    for name,info of @modelClass.fields when object.hasOwnProperty(name)
      fields[name] = object[name]

    return fields

  insert: (object) =>
    row = @objectToDatabase(object)

    # populate defaults
    for name, fieldDetails of @modelClass.fields
      if not row[name]? and fieldDetails.default?
        row[name] = fieldDetails.default

    idColumn = @idColumn

    if not row.created_at? and @tableSchema?.columns?.created_at?
      row.created_at = timestamp()

    if not row.source_ver? and @tableSchema?.columns?.source_ver?
      row.source_ver = @sourceVersion

    # Check to auto-generate an ID. This involves some retry logic on the (unlikely)
    # chance that our random ID is taken.

    if not idColumn?
      # no ID column
      return @db(@tableName).insert(row).then(-> row)

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
    if object.dataSource != 'local' or not object.original?
      throw new Error("DAO.update must be called on patch data: "+ object)

    where = {}
    where[@idColumn] = object[@idColumn]
    fields = @objectToDatabase(object)
    @db(@tableName).update(fields).where(where)
    .then -> object
    
  update2: (whereFunc, object) =>
    fields = @objectToDatabase(object)

    if Object.keys(fields).length == 0
      return Promise.resolve(object)
      
    query = @db(@tableName).update(fields)
      
    if typeof whereFunc == 'function'
      whereFunc(query)
    else
      query.where(whereFunc)

    query.then ->
      object

  modify: (whereFunc, modifyFunc, {allowInsert} = {}) =>
    allowInsert = allowInsert ? false

    original = null
    modified = null

    @find(whereFunc).then (items) =>
      if items.length > 1
        throw new Error("DAO.modify: found multiple items, only supports 1 item")

      original = items[0]

      if not allowInsert and not original?
        throw new Error("DAO.modify: item not found (table: #{@tableName})")

      modified = if original?

        @patchInstance(original)
      else
        @newInstance()

      modifyFunc(modified)

    .then =>
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

  del: (whereFunc) =>
    query = @db(@tableName).del()
    whereFunc(query)
    query

  @make: (args) ->
    new DAO(args)

provide('dao/user', -> new DAO(modelClass: depend('User')))
provide('dao/review', -> new DAO(modelClass: depend('Review')))
provide('dao/place', -> new DAO(modelClass: depend('Place')))

provide 'newDAO', -> (modelClass) ->
  new DAO({modelClass})
