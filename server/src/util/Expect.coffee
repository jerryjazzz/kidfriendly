
Expect =
  type: (value, t) ->
    if not value instanceof t
      throw new Error(value + " is not an instance of " + t)

  notNull: (val) ->
    if not val?
      throw new Error("expected not null")
