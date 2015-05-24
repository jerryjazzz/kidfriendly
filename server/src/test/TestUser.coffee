
class TestUser
  token: 'magic-test-user-token'
  id: 'test-user1'
  email: 'test-user-1@example.com'

  constructor: ->
    @userDao = depend('UserDAO')
    @voteDao = depend('VoteDAO')

  findOrCreate: ->
    where = (query) => query.where(user_id: @id)
    @userDao.modifyOrInsert where, (user) =>
      if not user.user_id?
        user.user_id = @id
      user.email = @email

  deleteAllVotes: ->
    @voteDao.del((query) -> query.where(user_id: @id))

provide('TestUser', -> new TestUser())
