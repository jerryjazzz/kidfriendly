
Promise = require('bluebird')

Database =
  UNIQUE_VIOLATION: '23505'
  INVALID_CATALOG_NAME: '3D000'

  randomId: (length = 10) ->
    digits = '0123456789'
    chars = for i in [0...(length-1)]
      digits[Math.floor(Math.random() * digits.length)]
    return '1' + chars.join('')

  existingKeyError: (key) ->
    return (err) ->
      console.log("checking #{err} for #{key}")
      (err.code == Database.UNIQUE_VIOLATION)\
        and err.detail.indexOf("Key (#{key})") != -1

  missingDatabaseError: (err) ->
    return err.code == Database.INVALID_CATALOG_NAME

