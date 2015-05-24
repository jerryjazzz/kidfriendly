
Promise = require('bluebird')

class UserEndpoint
  constructor: ->
    @app = depend('App')
    @reviewDao = depend('ReviewDAO')
    @userDao = depend('UserDAO')
    @testUser = depend('TestUser')
    @voteDao = depend('VoteDAO')
    @voteService = depend('VoteService')
    get = depend('ExpressGet')
    post = depend('ExpressPost')
    @route = require('express')()
    facebook = depend('Facebook')

    getValidatedUser = (req) =>
      user_id = req.params.user_id

      if req.query.token?
        if req.query.token == @testUser.token
          return @testUser.findOrCreate()
        else
          return Promise.reject("'token' not supported yet'")

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
        review.body = JSON.stringify(req.body.review)
        review.user_id = user_id
        review.place_id = place_id
        review.reviewer_name = req.body.review?.name

    post @route, '/:user_id/place/:place_id/vote', (req) =>

      user_id = req.user.user_id
      place_id = req.params.place_id
      vote = req.body.vote

      if not vote?
        throw new Error("'vote' is required")

      vote = parseInt(vote)

      if not (vote in [0,1,-1])
        throw new Error("'vote' can only be -1, 0, or 1")

      where = (query) -> query.where({user_id, place_id})

      @voteDao.modifyOrInsert where, (row) ->
        row.user_id = user_id
        row.place_id = place_id
        row.vote = vote
      .then =>
        @voteService.recalculateForPlace(place_id)
      .then =>
        console.log("vote submitted, user_id: #{user_id}, place_id: #{place_id}, vote: #{vote}")
        {result: 'ok'}


provide.class('endpoint/api/user', UserEndpoint)
