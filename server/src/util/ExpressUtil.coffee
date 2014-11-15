
ExpressUtil =
  wrap: (options, callback) ->
    handler = (req, res) ->
      callbackResult = callback(req)
      Promise.resolve(callbackResult)
        .then (result) ->
          statusCode = result.statusCode ? 200
          res.status(statusCode).send(result)
        .catch (err) ->
          statusCode = err.statusCode ? 500
          res.status(statusCode).send(JSON.stringify(err.stack ? err))

    return handler

