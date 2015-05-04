
class DAO
  constructor: ({@tableName, @fieldsToInsert, @fieldsToUpdate, @modelClass}) ->
    @db = depend('db')
    @dbInsert = depend('db.insert')
    @tableSchema  = depend('Configs').schema[table]
    @idColumn = tableSchema.primary_key

  find: (queryFunc) =>
    query = @db.select.apply(@fieldsToInsert).from(@tableName)
    queryFunc(query)
    query.then (rows) =>
      objects = for row in rows
        @modelClass.fromDatabase(row)
      objects

  findById: (id) =>
    where = {}
    where[@idColumn] = id
    @find((query) -> query.where(where))

  insert: (object) =>
    fields = {}
    for own k,v of object
      if k in @fieldsToInsert
        fields[k] = v

    @dbInsert(table, fields)

  update: (object) =>
    if object.dataSource != 'local' or not object.original?
      throw new Error("DAO.update must be called on patch data: "+ object)

    # TODO: Would be cool to only write modified fields.
    fields = {}
    for own k,v of object
      if k in @fieldsToUpdate
        fields[k] = v

    where = {}
    where[@idColumn] = object[@idColumn]
    @db(table).update(fields).where(where)

  modify: (queryFunc, modifyFunc, {allowInsert}) =>
    allowInsert = allowInsert ? false

    original = null

    find(whereFunc).then (items) ->
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
      modified

    .then (modified) =>
      if original?
        @update(modified)
      else
        @insert(modified)

  modifyMulti: (queryFunc, modifyFunc) =>
    # Fetch a list of ids, then map them to @modify.

    modifyOne = (id) =>
      @modify(id, modifyFunc)

    query = @app.db.select([@idColumn]).from(@tableName)
    queryFunc(query)
    query.then (results) ->
      for result in results
        result[@idColumn]
    .map(modifyOne, {concurrency: 1})

  @make: (args) ->
    new DAO(args)

provide('newDAO', DAO.make)
