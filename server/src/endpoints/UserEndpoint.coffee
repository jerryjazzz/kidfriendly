
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
          throw new Error("Facebook token is for different user")

        validatedUser

    get @route, '/:user_id', (req) =>
      getValidatedUser(req)

    get @route, '/:user_id/place/:place_id/review', (req) =>
      # SECURITY_TODO: Check auth token

      {user_id, place_id, token} = req.params

      ###
      if not token?
        {statusCode: 400, error: message: 'Token is required'}

      check = new UserAppCheckToken(@app)
      check.start(token)
      ###

      @app.db.select('review_id','place_id','body').from('review').where({user_id,place_id})
        .then (response) ->
          response[0] ? null

    post @route, '/:user_id/place/:place_id/review', (req) =>
      # TODO: Should check that user_id and place_id actually exist.
      # SECURITY_TODO: Check auth token

      {user_id, place_id, token} = req.params

      manualId = req.body.review_id # usually null

      whereFunc = (query) -> query.where({user_id, place_id})
      modifyFunc = (review) ->
        review.review_id = manualId
        review.body = JSON.stringify(req.body.review)
        review.user_id = user_id
        review.place_id = place_id
        review.reviewer_name = req.body.review.name

      @reviewDao.modify(whereFunc, modifyFunc, {allowInsert:true})

provide('endpoint/api/user', UserEndpoint)
