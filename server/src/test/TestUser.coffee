
class TestUser
  token: 'magic-test-user-token'
  id: 'test-user1'
  email: 'test-user-1@example.com'

  constructor: ->
    @user = depend('dao/user')
    @voteDao = depend('dao/vote')

  findOrCreate: ->
    where = (query) => query.where(user_id: @id)
    @user.modifyOrInsert where, (user) =>
      if not user.user_id?
        user.user_id = @id
      user.email = @email

  deleteAllVotes: ->
    user_id = @id
    @voteDao.del((query) -> query.where({user_id}))

provide.class(TestUser)
