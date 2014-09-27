
DateUtil =
  timestamp: (value=null) ->
    if value?
      date = new Date(value)
    else
      date = new Date()

    pad = (number) ->
      if ( number < 10 )
        return '0' + number
      return number

    return date.getUTCFullYear() +
        '-' + pad( date.getUTCMonth() + 1 ) +
        '-' + pad( date.getUTCDate() ) +
        ' ' + pad( date.getUTCHours() ) +
        ':' + pad( date.getUTCMinutes() ) +
        ':' + pad( date.getUTCSeconds() )

exports.DateUtil = DateUtil
