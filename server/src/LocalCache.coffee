
class LocalCache
  # TODO: handle TTL

  constructor: (@app) ->
    @data = {}

  set: (key, value) ->
    @data[key] = value

  get: (key) ->
    return @data[key]
