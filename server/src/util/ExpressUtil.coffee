
ExpressUtil =
  wrap: (options, callback) ->
    handler = (req, res) ->
      callbackResult = callback(req)
      Promise.resolve(callbackResult)
        .then (result) ->
          res.status(200).send(result)
        .catch (err) ->
          statusCode = err.statusCode ? 500
          res.status(statusCode).send(err)

    return handler

