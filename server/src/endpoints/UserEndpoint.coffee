
provide 'endpoint/api/user', ->
  Review = depend('dao/review')
  Vote = depend('dao/vote')
  VoteService = depend('VoteService')
  UserAuthentication = depend('UserAuthentication')

  'use /:user_id*': (req, res, next) ->
    user_id = req.params.user_id

    UserAuthentication.fromRequest(req)
    .then (user) ->
      if not user?
        return Promise.reject("no user token")

      if user_id != 'me' and user.user_id != user_id
        return Promise.reject('Token is for a different user')

      req.user = user
      next()

    .catch (err) ->
      console.log("getValidatedUser error: #{err.stack}")
      res.sendRendered({statusCode: 500, error: err})

  '/:user_id': (req) ->
    # Logging to chase a bug around bad user IDs
    if req.params.user_id == 'me'
      console.log("/user/me returning #{req.user.user_id} for request: #{JSON.stringify(req.query)}")

    req.user.toClient()

  '/:user_id/reviews': (req) ->
    user_id = req.user.user_id
    Review.find((query) -> query.where({user_id}))
    .then (reviews) ->
      review.toClient() for review in reviews

  '/:user_id/place/:place_id/review': (req) ->
    user_id = req.user.user_id
    place_id = req.params.place_id
    Review.findOne((query) -> query.where({user_id,place_id}))
    .then (place) -> place.toClient()

  'post /:user_id/place/:place_id/review': (req) ->

    console.log('received review post with body: ', req.body)

    user_id = req.user.user_id
    place_id = req.params.place_id

    where = (query) -> query.where({user_id, place_id})

    Review.modifyOrInsert where, (review) ->
      review.body = JSON.stringify(req.body.review)
      review.user_id = user_id
      review.place_id = place_id
      review.reviewer_name = req.body.review?.name

  'post /:user_id/place/:place_id/vote': (req) ->

    user_id = req.user.user_id
    place_id = req.params.place_id
    vote = req.body.vote

    if not vote?
      throw new Error("'vote' is required")

    vote = parseInt(vote)

    if not (vote in [0,1,-1])
      throw new Error("'vote' can only be -1, 0, or 1")

    where = (query) -> query.where({user_id, place_id})

    Vote.modifyOrInsert where, (row) ->
      row.user_id = user_id
      row.place_id = place_id
      row.vote = vote
    .then =>
      VoteService.recalculateForPlace(place_id)
    .then =>
      console.log("vote submitted, user_id: #{user_id}, place_id: #{place_id}, vote: #{vote}")
      {result: 'ok'}

