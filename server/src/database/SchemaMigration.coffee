
Promise = require('bluebird')


class ColumnDefinition
  # Definition for our *desired* state of a single column. This data comes from schema config.
  constructor: (@name, {@type, @options, @foreign_key, @change_type_from}) ->

  definitionStr: ->
    if @foreign_key?
      return "foreign key (#{@name}) references #{@foreign_key}"
    else
      return "#{@name} #{@type} #{@options ? ''}"

  getMigrationAction: (tableName, existingColumn) ->
    if existingColumn.definitionMatches(@type)
      return null

    if @change_type_from and (existingColumn.type in @change_type_from)
      return {type: 'change_type', to: this}
    else
      throw "Type mismatch: Field '#{@name}' on table '#{tableName}' currently has type "\
        +"'#{existingColumn.type}' and the defined type is '#{@type}'."

class ExistingColumn
  # State of a column as it exists now in the database.
  constructor: ({@name, @type}) ->

  definitionMatches: (typeDef) ->
    if typeDef == @type
      return true

    if typeDef == 'serial' and @type == 'integer'
      return true

    if @type == 'USER-DEFINED'
      return true

    return false

class SchemaMigration
  constructor: (@app) ->

  start: ->
    @getExistingTableNames()
    .then(@updateTypes)
    .then(@updateEveryTable)

  getExistingTableNames: ->
    @app.db.select('table_name').from('information_schema.tables').where(table_schema:'public')
      .then (rows) =>
        #console.log('existing table names = ', rows)
        @existingTableNames = (row.table_name for row in rows)

  updateTypes: =>
    Promise.all(\
      for typename, details of (@app.config.schema._types ? [])
        @app.db.select('typname').from('pg_type').where(typname:typename)
        .then (existing) =>
          if not existing[0]?
            @app.log("SchemaMigration: creating type #{typename}")
            @app.db.raw("create type #{typename} as #{details.decl}")
    )

  updateEveryTable: =>
    Promise.all(\
      for tableName, table of @app.config.schema
        if tableName == '_types'
          continue
        @updateTable(tableName, table)
    )


  updateTable: (tableName, table) ->
    if not (tableName in @existingTableNames)
      @createTable(tableName, table)
    else
      @updateExistingTable(tableName, table)

  createTable: (tableName, table) ->
    columnDefinitions = (new ColumnDefinition(columnName, column) for columnName, column of table.columns)
    strs = (column.definitionStr() for column in columnDefinitions)
    @app.log("SchemaMigration: creating table #{tableName}")
    return @app.db.raw("create table #{tableName} (#{strs.join(', ')})")

  updateExistingTable: (tableName, table) ->
    @getExistingFields(tableName).then (existingFields) =>
      #console.log('existingFields1 = ', existingFields)
      columnDefinitions = (new ColumnDefinition(columnName, column) for columnName, column of table.columns)
      changeList = @buildChangeList(tableName, columnDefinitions, existingFields)
      @runChangeList(tableName, changeList)

  buildChangeList: (tableName, columnDefinitions, existingFields) ->
    changes = []

    for column in columnDefinitions
      existing = existingFields[column.name]

      if existing?
        if (action = column.getMigrationAction(tableName, existing))?
          changes.push(action)
      else
        changes.push({type: 'add', column: column})

    return changes

  runChangeList: (tableName, changeList) ->
    if changeList.length == 0
      return

    @app.log("SchemaMigration: updating table #{tableName}")

    #console.log("table #{tableName} needs change list ", changeList)
    queries = for change in changeList
      switch change.type
        when 'add'
          @app.log("SchemaMigration: adding column #{change.column.name} to table #{tableName}")
          @app.db.raw("alter table #{tableName} add column #{change.column.definitionStr()}")

        when 'change_type'
          @app.log("SchemaMigration: changing type of column #{change.to.name} to #{change.to.type} on "\
            +"table #{tableName}")

          @app.db.raw("alter table #{tableName} alter column #{change.to.name} type #{change.to.type}")

    Promise.all(queries)

  getExistingFields: (tableName) ->
    @app.db.select('column_name','data_type','character_maximum_length').from('information_schema.columns').where(table_name:tableName)
      .then (rows) =>
        #console.log('result from information_schema = ', rows)
        result = {}
        for row in rows
          name = row.column_name
          result[name] = new ExistingColumn(name: name, type: @columnInfoToDefinition(row))

        return result

  columnInfoToDefinition: (info) ->
    switch
      when info.data_type == 'character varying'
        "varchar(#{info.character_maximum_length})"
      when info.data_type == 'timestamp without time zone'
        "timestamp"
      else
        info.data_type

