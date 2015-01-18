
ObjectUtil =
  isObject: (val) ->
    return val? and typeof val == 'object'

  merge: (left, right) ->
    result = {}
    for k,v of left
      result[k] = v
    for k,rightV of right
      leftV = left[k]
      if leftV? and ObjectUtil.isObject(leftV) and ObjectUtil.isObject(rightV)
        result[k] = ObjectUtil.merge(leftV, rightV)
      else
        result[k] = rightV
    return result

exports.ObjectUtil = ObjectUtil
