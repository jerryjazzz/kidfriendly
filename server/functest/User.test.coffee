
helper = require('./TestHelper')
{expect} = require('chai')

describe 'User', ->

  token = helper.testToken

  it '/user/me', ->
    helper.api.userMe({token})
    .then (user) ->
      expect(user.user_id).to.equal('test-user1')
      expect(user.email).to.equal('test-user-1@example.com')

  it '/user/test-user1', ->
    helper.api.userDetails('test-user1', {token})
    .then (user) ->
      expect(user.user_id).to.equal('test-user1')
      expect(user.email).to.equal('test-user-1@example.com')

  it "can't get user details for a different user", ->
    helper.assertThrows helper.api.userDetails('test-user2', {token}), (err) ->
      expect(err.statusCode).to.equal(500)
