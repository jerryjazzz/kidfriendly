
Request = require('request')
Promise = require('bluebird')
{expect} = require('chai')

require('mocha-as-promised')()

baseUrl = switch process.env['TARGET_SERVER']
  when 'local'
    'http://localhost:3000'
  when 'prod'
    'http://kidfriendlyreviews.com'
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
  placeDetails: (placeId) ->
    request
      url: "/api/place/#{placeId}/details"

  placeReviews: (placeId) ->
    request
      url: "/api/place/#{placeId}/details/reviews"

  anyPlace: ->
    request
      url: '/api/place/any'

  search: (options) ->
    request
      url: '/api/search/nearby'
      qs: options

assertPlace = (place) ->
  expect(place.place_id).to.exist()
  expect(place.name).to.exist()
  expect(place.lat).to.exist()
  expect(place.long).to.exist()
  expect(place.price).to.exist()

exports.api = Api
exports.assertPlace = assertPlace
