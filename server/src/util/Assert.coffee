
Assert =
  type: (value, t) ->
    if not value instanceof t
      throw new Error(value + " is not an instance of " + t)

  notNull: (val, name) ->
    if not val?
      msg = "expected not null"
      if name?
        msg += ": " + name
      throw new Error(msg)

global.Assert = Assert
