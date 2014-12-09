
ExpressUtil =
  wrap: (options, callback) ->
    handler = (req, res) ->
      callbackResult = callback(req)
      Promise.resolve(callbackResult)
        .then (result) ->
          statusCode = result.statusCode ? 200
          json = JSON.stringify(result, null, '\t')
          res.status(statusCode).send(json)
        .catch (err) ->
          statusCode = err.statusCode ? 500
          res.status(statusCode).send(JSON.stringify(err.stack ? err))

    return handler

