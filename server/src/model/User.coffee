
class User
  constructor: (fields) ->
    for k,v of fields
      this[k] = v
    @dataSource = null

  @fromDatabase: (fields) ->
    user = new User(fields)
    user.dataSource = 'db'
    Object.freeze(user)
    return user

  @make: (fields) ->
    user = new User(fields)
    user.dataSource = 'local'
    return user

  toClient: ->
    fields = {}
    for k in ['user_id', 'email']
      fields[k] = this[k]
    fields

provide('User', -> User)
