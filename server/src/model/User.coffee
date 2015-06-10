
class User
  constructor: (fields) ->
    for k,v of fields
      this[k] = v
    @dataSource = null

  @tableName: 'users'

  @fields:
    user_id: {}
    first_name: {}
    last_name: {}
    email: {}
    facebook_id: {}
    created_at: {}
    updated_at: {}

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
