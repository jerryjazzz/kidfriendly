
ExpressUtil =
  wrap: (options, callback) ->
    handler = (req, res) ->
      callbackResult = callback(req)
      Promise.resolve(callbackResult)
        .then (result) ->
          statusCode = result?.statusCode ? 200
          json = JSON.stringify(result, null, '\t')
          res.status(statusCode).send(json)
        .catch (err) ->
          statusCode = err?.statusCode ? 500
          res.set('Content-Type', 'text/plain')
          res.status(statusCode).send(err.stack ? err)

    return handler

