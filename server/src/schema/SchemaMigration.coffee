
Promise = require('bluebird')

class ColumnDefinition
  # Definition for our *desired* state of a single column. This data comes from schema config.
  constructor: ({@name, @type, @options, @foreign_key, @change_type_from}) ->

  definitionStr: ->
    if @foreign_key?
      return "foreign key (#{@name}) references #{@foreign_key}"
    else
      return "#{@name} #{@type} #{@options ? ''}"

  getMigrationAction: (tableName, existingColumn) ->
    if @type != existingColumn.type

      if @change_type_from and (existingColumn.type in @change_type_from)
        return {type: 'change_type', to: this}
      else
        throw "Type mismatch: Field '#{@name}' on table '#{tableName}' currently has type "\
          +"'#{existingColumn.type}' and the defined type is '#{@type}'."

    return null

class ExistingColumn
  # State of a column as it exists now in the database. Comes from a "show columns" query.
  constructor: ({@name, @type}) ->

class SchemaMigration
  constructor: (@app) ->

  apply: ->
    tableDefinitions = {}
    for tableName, tableDetails of @app.config.schema
      tableDefinitions[tableName] = for column in tableDetails.columns
        new ColumnDefinition(column)
      
    Promise.all(for tableName, columnDefinitions of tableDefinitions
      @updateTable(tableName, columnDefinitions)
    )

  updateTable: (tableName, columnDefinitions) ->
    @getExistingFields(tableName)
      .then (existingFields) =>
        if not existingFields?
          return @createTable(tableName, columnDefinitions)

        return @upgradeExistingTable(tableName, columnDefinitions, existingFields)

  createTable: (tableName, columnDefinitions) ->
    fieldStrs = for field in columnDefinitions
      field.definitionStr()

    @app.log("SchemaMigration: creating table #{tableName}")
    return @app.query "create table #{tableName} (#{fieldStrs.join(', ')})"

  upgradeExistingTable: (tableName, columnDefinitions, existingFields) ->
    existingIndex = 0
    pendingChanges = []

    existingNameIndex = (name) ->
      for index, existing of existingFields
        if existing.name == name
          return index
      null

    # First build up the pendingChanges list, before touching the DB. Check for bad conditions along the way.
    for definitionIndex, column of columnDefinitions
      definitionIndex = parseInt(definitionIndex)
      nextExisting = existingFields[existingIndex]

      if nextExisting? and column.name == nextExisting.name
        action = column.getMigrationAction(tableName, nextExisting)
        if action?
          pendingChanges.push(action)

        existingIndex += 1

      else
        if (foundIndex = existingNameIndex(column.name))?
          throw "Tried to add field '#{column.name}' to table '#{tableName}' at index "\
            +"#{existingIndex}, but the field already exists at index #{foundIndex}"

        where = if definitionIndex == 0
          'first'
        else
          "after #{columnDefinitions[definitionIndex - 1].name}"

        pendingChanges.push({type: 'add', column: column, where})

    if existingIndex < existingFields.length
      throw "Not all existing fields found in table #{tableName}, such as field "\
        +"'#{existingFields[existingIndex].name}'. (field deletion is not supported.)"

    # If we made it here successfully, then commit the toAdd list.
    queries = for change in pendingChanges
      switch change.type
        when 'add'
          @app.log("SchemaMigration: adding column #{change.column.name} to table #{tableName}")
          @app.query("alter table #{tableName} add column #{change.column.definitionStr()} #{change.where}")

        when 'change_type'
          @app.log("SchemaMigration: changing type of column #{change.to.name} to #{change.to.type} on "\
            +"table #{tableName}")

          definitionStr = change.to.definitionStr()

          # SQL doesn't like if you mention 'primary key' in the alter table statement.
          definitionStr = definitionStr.replace('primary key', '')

          @app.query("alter table #{tableName} modify column #{definitionStr}")

    Promise.all(queries)

  getExistingFields: (tableName) ->
    @app.query("show columns from #{tableName}")
      .catch ((err) -> err.code == 'ER_NO_SUCH_TABLE'), ->
        # resolve to null for 'no such table'
        null
      .then (columns) ->
        if columns?
          # rename the field names provided by SQL. Other data from SQL that we aren't currently
          # using: 'Null', 'Key', 'Default', 'Extra'
          for column in columns
            new ExistingColumn(name: column.Field, type: column.Type)
