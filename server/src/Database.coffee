
bluebird = require('bluebird')

Database =
  randomId: (range = 100000000) ->
    Math.floor(Math.random() * range)

  writeRow: (server, table, data, {generateId} = {}) ->
    new bluebird (resolve, reject) ->
      send = (attempts) ->
        if generateId
          data.id = Database.randomId()

        server.db.query "INSERT INTO #{table} SET ?", data, (err, result) =>

          if err? and err.code == 'ER_DUP_ENTRY' and attempts < 5
            send(attempts + 1)
          else if err?
            resolve(error: err)
          else
            resolve(id: data.id)

      send(0)
