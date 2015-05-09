
class UserDAO
  constructor: ->
    @dao = depend('newDAO')(modelClass: depend('User'))

    ###
    dao = depend('DAO').make
      table: 'users'
      fieldsToInsert: ['user_id', 'email', 'facebook_id', 'created_at']
      fieldsToUpdate: ['updated_at']
      modelClass: depend('User')

    for k,v of dao
      this[k] = v
    ###

