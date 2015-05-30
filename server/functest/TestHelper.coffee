
Request = require('request')
Promise = require('bluebird')
{expect} = require('chai')

baseUrl = switch process.env['TARGET_SERVER']
  when 'local'
    'http://localhost:3000'
  when 'prod'
    'https://kidfriendlyreviews.com'
  else
    throw new Error("unrecognized TARGET_SERVER")
    
request = (args) ->
  args.json = args.json ? true
  args.url = baseUrl + args.url
  new Promise (resolve, reject) =>
    Request args, (error, message, body) =>
      if error?
        reject(error)
      else if message.statusCode != 200
        reject(new Error("status code #{message.statusCode}, body: #{body}"))
      else
        resolve(body)

Api =
  placeDetails: (placeId, options) ->
    request
      url: "/api/place/#{placeId}/details"
      qs: options

  placeReviews: (placeId, options) ->
    request
      url: "/api/place/#{placeId}/details/reviews"
      qs: options

  getReview: (placeId, token) ->
    request
      url: "/api/user/me/place/#{placeId}/review"
      qs: {token}

  submitReview: (placeId, token, body) ->
    request
      url: "/api/user/me/place/#{placeId}/review"
      method: 'POST'
      qs: {token}
      body: body

  anyPlace: ->
    request
      url: '/api/place/any'

  search: (options) ->
    request
      url: '/api/search/nearby'
      qs: options

  searchForTestPlace: (options) ->
    options.lat = 30
    options.long = 171
    request
      url: '/api/search/nearby'
      qs: options

  userMe: (options) ->
    request
      url: '/api/user/me'
      qs: options

  userDetails: (user_id, options) ->
    request
      url: "/api/user/#{user_id}"
      qs: options

  vote: (token, placeId, vote) ->
    request
      url: "/api/user/me/place/#{placeId}/vote"
      qs: {token}
      method: 'POST'
      body: {vote}

  testStart: ->
    request
      url: '/api/test/start'
      method: 'POST'
      body: {}

  testCleanup: ->
    request
      url: '/api/test/cleanup'
      method: 'POST'
      body: {}

  testDeleteVotes: ->
    request
      url: '/api/test/delete-votes'
      method: 'POST'
      body: {}

assertPlace = (place) ->
  expect(place.place_id).to.exist()
  expect(place.name).to.exist()
  expect(place.lat).to.exist()
  expect(place.long).to.exist()

exports.api = Api
exports.assertPlace = assertPlace

exports.testToken = 'magic-test-user-token'
exports.testPlaceId = 'testplace1'
