
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
    for k in ['user_id','email','facebook_id']
      fields[k] = this[k]
    fields

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
