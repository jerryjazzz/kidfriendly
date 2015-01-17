
Map =
  fromList: (list, key) ->
    out = {}
    if key instanceof Function
      for item in list
        out[key(item)] = item
    else
      for item in list
        out[item[key]] = item
    return out
