
class TestUser
  token: 'magic-test-user-token'
  id: 'test-user1'
  email: 'test-user-1@example.com'

  constructor: ->
    @userDao = depend('UserDAO')

  findOrCreate: ->
    where = (query) => query.where(user_id: @id)
    @userDao.modifyOrInsert where, (user) =>
      console.log('modifyOrInsert 1', user)
      if not user.user_id?
        user.user_id = @id
      user.email = @email
      console.log('modifyOrInsert 2', user)

provide('TestUser', -> new TestUser())
