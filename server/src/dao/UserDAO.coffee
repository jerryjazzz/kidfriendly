
class UserDAO
  constructor: ->
    dao = depend('DAO').make
      table: 'users'
      fieldsToInsert: ['user_id', 'email', 'created_at']
      fieldsToUpdate: ['updated_at']
      modelClass: depend('User')

    for k,v of dao
      this[k] = v

  # Inherited from DAO:
  #   find(queryFunc)
  #   findById(user_id)
  #   insert(user)

provide('UserDAO', UserDAO)
