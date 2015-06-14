
Promise = require('bluebird')

class ColumnDefinition
  # Definition for our *desired* state of a single column. This data comes from schema config.
  constructor: (@name, {@type, @options, @foreign_key, @change_type_from}) ->

    if @type == 'id'
      @type = 'varchar(10)'

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
  constructor: ->
    @db = depend('db')
    @config = depend('Configs')

  start: ->
    @getExistingTableNames()
    .then(@updateTypes)
    .then(@updateEveryTable)

  getExistingTableNames: ->
    @db.select('table_name').from('information_schema.tables').where(table_schema:'public')
      .then (rows) =>
        @existingTableNames = (row.table_name for row in rows)

  updateTypes: =>
    Promise.all(\
      for typename, details of (@config.schema._types ? [])
        @db.select('typname').from('pg_type').where(typname:typename)
        .then (existing) =>
          if not existing[0]?
            #console.log("SchemaMigration: creating type #{typename}")
            @db.raw("create type #{typename} as #{details.decl}")
    )

  updateEveryTable: =>
    Promise.all(\
      for tableName, tableDetails of @config.schema when tableName != '_types'
        @updateTable(tableName, tableDetails)
    )


  updateTable: (tableName, table) ->
    if not (tableName in @existingTableNames)
      console.log('create table: ', tableName)
      @createTable(tableName, table)
    else
      # console.log('update table: ', tableName)
      @updateExistingTable(tableName, table)

  createTable: (tableName, tableDetails) ->

    if tableDetails.use_model?
      # New style
      dao = depend(tableDetails.use_model)
      columnDefinitions = (new ColumnDefinition(columnName, column) for columnName, column of dao.modelClass.fields)
      #console.log('new style = ', dao.fields)
      #console.log(JSON.stringify(columnDefinitions))
    else
      columnDefinitions = (new ColumnDefinition(columnName, column) for columnName, column of tableDetails.columns)

    strs = (column.definitionStr() for column in columnDefinitions)
    console.log("SchemaMigration: creating table #{tableName}")
    return @db.raw("create table #{tableName} (#{strs.join(', ')})")

  updateExistingTable: (tableName, tableDetails) ->

    # New style
    if tableDetails.use_model?
      dao = depend(tableDetails.use_model)
      columnDefinitions = (new ColumnDefinition(columnName, column) for columnName, column of dao.modelClass.fields)
      #console.log('new style1 = ', dao)
      #console.log('new style = ', dao.fields)
      #console.log(JSON.stringify(columnDefinitions))
    else
      columnDefinitions = (new ColumnDefinition(columnName, column) for columnName, column of tableDetails.columns)

    @getExistingFields(tableName).then (existingFields) =>
      #console.log('existingFields1 = ', existingFields)

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

    console.log("SchemaMigration: updating table #{tableName}")

    #console.log("table #{tableName} needs change list ", changeList)
    queries = for change in changeList
      switch change.type
        when 'add'
          console.log("SchemaMigration: adding column #{change.column.name} to table #{tableName}")
          @db.raw("alter table #{tableName} add column #{change.column.definitionStr()}")

        when 'change_type'
          console.log("SchemaMigration: changing type of column #{change.to.name} to #{change.to.type} on "\
            +"table #{tableName}")

          @db.raw("alter table #{tableName} alter column #{change.to.name} type #{change.to.type}")

    Promise.all(queries)

  getExistingFields: (tableName) ->
    @db.select('column_name','data_type','character_maximum_length').from('information_schema.columns').where(table_name:tableName)
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

provide.class(SchemaMigration)
