
class TweakValue
  constructor: (fields) ->
    for k,v of fields
      this[k] = v

  @tableName: 'tweak_values'

  @fields:
    name: {}
    value: {}

  @make: (fields) ->
    obj = new TweakValue(fields)
    obj.dataSource = 'local'
    return obj

  @fromDatabase: (fields) ->
    value = null
    try
      value = JSON.parse(fields.value)

    obj = new TweakValue(name: fields.name, value: value)
    obj.dataSource = 'db'
    return obj

  toDatabase: ->
    name: @name
    value: JSON.stringify(@value)

provide 'model/TweakValue', -> TweakValue
provide 'TweakValueDAO', -> depend('newDAO')(modelClass: TweakValue)
