
helper = require('./TestHelper')
{expect} = require('chai')

describe 'User', ->

  token = helper.testToken

  describe '/user/me', ->
    helper.api.userMe(token)
    .then (user) ->
      expect(user.user_id).to.equal('test-user1')
      expect(user.email).to.equal('test-user-1@example.com')
