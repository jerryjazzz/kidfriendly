
Promise = require('bluebird')

PromiseUtil =
  retry: (func) ->
    doAttempt = ->
      magicRetryValue = {magic_retry_value: true}

      result = func(magicRetryValue)
      Promise.resolve(result)
      .then (result) ->
        if result is magicRetryValue
          doAttempt()
        else
          result

    doAttempt()
