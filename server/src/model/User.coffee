
class User
  constructor: (fields) ->
    for k,v of fields
      this[k] = v
    @dataSource = null
    @auth = {}

  @fromDatabase: (fields) ->
    user = new User(fields)
    user.dataSource = 'db'
    Object.freeze(user)
    return user

  @make: (fields) ->
    user = new User(fields)
    user.dataSource = 'local'
    return user

provide('User', -> User)
