
class DAOCommon
  modify: (dao, whereFunc, modifyFunc, {allowInsert}) ->
    allowInsert = allowInsert ? false

    originalItem = null

    dao.get(whereFunc)
    .then (items) ->
      if items.length > 1
        return Promise.reject("DAOCommon.modify: found multiple items, only supports 1 item")

      originalItem = items[0]

      if not allowInsert and not originalItem?
        return Promise.reject("DAOCommon.modify: item not found")

      modified = if originalItem?
        originalItem.startPatch()
      else
        dao.modelClass.make()

      modifyFunc(modified)
      modified

    .then (modified) ->
      if originalItem?
        dao.save(modified)
      else
        dao.insert(modified)

provide('DAOCommon', DAOCommon)
