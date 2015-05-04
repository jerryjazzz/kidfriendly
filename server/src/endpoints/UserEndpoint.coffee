
Promise = require('bluebird')

class UserEndpoint
  constructor: ->
    @app = depend('App')
    @reviewDao = depend('ReviewDAO')
    get = depend('ExpressGet')
    post = depend('ExpressPost')
    @route = require('express')()
    facebook = depend('Facebook')

    getValidatedUser = (req) ->
      user_id = req.params.user_id
      facebook_token = req.query.facebook_token

      if not facebook_token?
        return Promise.reject("facebook_token is required")

      facebook.validateToken(facebook_token)
      .then (validatedUser) ->
        if user_id != 'me' and validatedUser.user_id != user_id
          return Promise.reject("Facebook token is for a different user")

        validatedUser

    @route.use '/:user_id*', (req, res, next) =>
      getValidatedUser(req)
      .then (user) ->
        req.user = user
        next()
      .catch (err) ->
        console.log("getValidatedUser error: #{err}")
        res.sendRendered({error: err})

    get @route, '/:user_id', (req) =>
      req.user.toClient()

    get @route, '/:user_id/reviews', (req) =>
      user_id = req.user.user_id
      @reviewDao.find((query) -> query.where({user_id}))
      .then (reviews) ->
        review.toClient() for review in reviews

    get @route, '/:user_id/place/:place_id/review', (req) =>
      user_id = req.user.user_id
      place_id = req.params.place_id
      @reviewDao.findOne((query) -> query.where({user_id,place_id}))
      .then (place) -> place.toClient()

    post @route, '/:user_id/place/:place_id/review', (req) =>

      user_id = req.user.user_id
      place_id = req.params.place_id

      where = (query) -> query.where({user_id, place_id})

      @reviewDao.modifyOrInsert where, (review) ->
        review.review_id = manualId
        review.body = JSON.stringify(req.body.review)
        review.user_id = user_id
        review.place_id = place_id
        review.reviewer_name = req.body.review.name

provide('endpoint/api/user', UserEndpoint)
