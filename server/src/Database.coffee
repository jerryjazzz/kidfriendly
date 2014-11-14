
Promise = require('bluebird')

Database =
  randomId: (range = 100000000) ->
    '' + Math.floor(Math.random() * range)

  # Deprecated:
  writeRow: (app, table, data, {generateId} = {}) ->
    new Promise (resolve, reject) ->
      send = (attempts) ->
        if generateId
          data.id = Database.randomId()

        app.db.query "INSERT INTO #{table} SET ?", data, (err, result) =>

          if generateId and err? and err.code == 'ER_DUP_ENTRY' and attempts < 5
            send(attempts + 1)
          else if err?
            resolve(error: err)
          else
            resolve(id: data.id)

      send(0)
