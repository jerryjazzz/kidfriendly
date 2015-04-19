
class DAO
  constructor: ->

  make: ({table, fieldsToInsert, fieldsToUpdate, modelClass}) ->
    if not modelClass.fromDatabase?
      throw new Error("DAOFactory.make requires modelClass.fromDatabase")

    db = depend('db')
    dbInsert = depend('db.insert')
    tableSchema  = depend('Configs').schema[table]
    idColumn = tableSchema.primary_key

    find = (queryFunc) ->
      query = db.select.apply(fieldsToInsert).from(table)
      queryFunc(query)
      query.then (rows) ->
        objects = for row in rows
          modelClass.fromDatabase(row)
        objects

    findById = (id) ->
      where = {}
      where[idColumn] = id
      find((query) -> query.where(where))

    insert = (object) ->
      fields = {}
      for own k,v of object
        if k in fieldsToInsert
          fields[k] = v

      dbInsert(table, fields)

    return {find, findById, insert}

provide('DAO', DAO)
