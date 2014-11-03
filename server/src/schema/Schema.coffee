
Promise = require('bluebird')

class Schema
  constructor: (@app) ->

  apply: ->
    Promise.all(for tableName, latestFields of @getLatestDefinitions()
      @applyTable(tableName, latestFields)
    )

  applyTable: (tableName, latestFields) ->
    @getExistingFields(tableName)
      .then (existingFields) =>
        if not existingFields?
          return @createTable(tableName, latestFields)

        return @upgradeExistingTable(tableName, latestFields, existingFields)

  createTable: (tableName, latestFields) ->
    fieldStrs = for field in latestFields
      "#{field.name} #{field.type} #{field.options}"

    return @app.query "create table #{tableName} (#{fieldStrs.join(', ')})"

  upgradeExistingTable: (tableName, latestFields, existingFields) ->
    console.log('existing fields = ', existingFields)

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
          console.log('type error')
          throw "SQL field type change not supported. Field #{latestField.name} "\
            +"currently has type #{nextExisting.type} and the latest type is #{latestField.type}"

        existingIndex += 1

      else
        if (foundIndex = existingNameIndex(latestField.name))?
          console.log('existing name error')
          return Promise.reject("Tried to add field #{latestField.name} at index #{existingIndex}, "\
            +"but the field already exists at index #{foundIndex}")
        

        where = if latestFieldIndex == 0
          'first'
        else
          "after #{latestFields[latestFieldIndex - 1].name}"

        toAdd.push({field: latestField, where})

    console.log('toAdd list = ', toAdd)

    # If we made it here successfully, then commit the toAdd list.
    queries = for {field, where} in toAdd
      @app.query("alter table #{tableName} add column #{field.name} #{field.type} #{field.options} #{where}")

    Promise.all(queries)

  getExistingFields: (tableName) ->
    @app.query("show columns from #{tableName}")
      .catch ((err) -> err.code == 'ER_NO_SUCH_TABLE'), ->
        # resolve to null for 'no such table'
        null
      .then (existingFields) ->
        if existingFields?
          # convert Sql's names. Not currently using: 'Null', 'Key', 'Default', 'Extra'
          for field in existingFields
            name: field.Field
            type: field.Type

  getLatestDefinitions: ->
    return tables =
      test: [
        {name: 'id', type: 'int(11)', options: 'not null primary key'}
        {name: 'id2', type: 'int(11)', options: 'not null'}
      ]


