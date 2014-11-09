
Promise = require('bluebird')

class SchemaMigration
  constructor: (@app) ->

  apply: ->
    Promise.all(for tableName, latestFields of @app.config.schema
      @updateTable(tableName, latestFields)
    )

  getFieldDefinitionStr: (field) ->
    if field.foreign_key?
      return "foreign key (#{field.name}) references #{field.foreign_key}"
    else
      return "#{field.name} #{field.type} #{field.options ? ''}"

  updateTable: (tableName, latestFields) ->
    @getExistingFields(tableName)
      .then (existingFields) =>
        if not existingFields?
          return @createTable(tableName, latestFields)

        return @upgradeExistingTable(tableName, latestFields, existingFields)

  createTable: (tableName, latestFields) ->
    fieldStrs = for field in latestFields
      @getFieldDefinitionStr(field)

    @app.log("SchemaMigration: creating table #{tableName}")
    return @app.query "create table #{tableName} (#{fieldStrs.join(', ')})"

  upgradeExistingTable: (tableName, latestFields, existingFields) ->
    existingIndex = 0
    toAdd = []

    existingNameIndex = (name) ->
      for index, existing of existingFields
        if existing.name == name
          return index
      null

    # First build up the toAdd list, before touching the DB. Check for bad conditions along the way.
    for latestFieldIndex, latestField of latestFields
      nextExisting = existingFields[existingIndex]

      if nextExisting? and latestField.name == nextExisting.name
        if latestField.type != nextExisting.type
          throw "Field '#{latestField.name}' on table '#{tableName}' currently has type "\
            +"#{nextExisting.type} and the latest type is #{latestField.type}. (type change "\
            +"is not supported)"

        existingIndex += 1

      else
        if (foundIndex = existingNameIndex(latestField.name))?
          throw "Tried to add field '#{latestField.name}' to table '#{tableName}' at index "\
            +"#{existingIndex}, but the field already exists at index #{foundIndex}"

        where = if latestFieldIndex == 0
          'first'
        else
          "after #{latestFields[latestFieldIndex - 1].name}"

        toAdd.push({field: latestField, where})

    if existingIndex < existingFields.length
      throw "Not all existing fields found in table #{tableName}, such as field "\
        +"'#{existingFields[existingIndex].name}'. (field deletion is not supported.)"

    # If we made it here successfully, then commit the toAdd list.
    queries = for {field, where} in toAdd
      @app.log("SchemaMigration: adding field #{field.name} to table #{tableName}")
      @app.query("alter table #{tableName} add column #{@getFieldDefinitionStr(field)} #{where}")

    Promise.all(queries)

  getExistingFields: (tableName) ->
    @app.query("show columns from #{tableName}")
      .catch ((err) -> err.code == 'ER_NO_SUCH_TABLE'), ->
        # resolve to null for 'no such table'
        null
      .then (existingFields) ->
        if existingFields?
          # rename the field names provided by SQL. Other fields we aren't currently using:
          # 'Null', 'Key', 'Default', 'Extra'
          for field in existingFields
            name: field.Field
            type: field.Type
