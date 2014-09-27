
Promise = require('bluebird')

Database =
  randomId: (range = 100000000) ->
    Math.floor(Math.random() * range)

  insertSourceVersion: (server, gitCommit) ->
    new Promise (resolve, reject) =>
      data =
        sha1: gitCommit.sha1
        commit_date: gitCommit.timestamp
        first_deployed_at: DateUtil.timestamp()

      server.db.query 'select id from source_version where sha1=?', [data.sha1], (err, result) ->
        if result.length > 0
          resolve(result[0].id)
          return

        server.db.query 'insert ignore into source_version set ?; select id from source_version where sha1=?', \
          [data, data.sha1], (err, result) ->
            resolve(result[1][0].id)

  writeRow: (server, table, data, {generateId} = {}) ->
    new Promise (resolve, reject) ->
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
