
class User
  constructor: (fields) ->
    for k,v of fields
      this[k] = v
    @dataSource = null

  @tableName: 'users'

  @fields:
    user_id: {}
    email: {}
    facebook_id: {}
    created_at: {}
    updated_at: {}

  toDatabase: ->
    fields = {}
    for k in ['email','facebook_id']
      fields[k] = this[k]
    fields

  @fromDatabase: (fields) ->
    user = new User(fields)
    user.dataSource = 'db'
    Object.freeze(user)
    return user

  @make: (fields) ->
    user = new User(fields)
    user.dataSource = 'local'
    return user

  startPatch: ->
    if this.dataSource != 'db'
      throw Error("User.startPatch can only be called on original DB data")
    user = new User(this)
    user.original = this
    user.dataSource = 'local'
    return user

  toClient: ->
    fields = {}
    for k in ['user_id', 'email']
      fields[k] = this[k]
    fields

provide('User', -> User)
