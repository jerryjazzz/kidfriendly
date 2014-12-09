Promise = require('bluebird')

class SourceUtil
  constructor: (@app) ->

  getCurrentGitCommit: ->
    new Promise (resolve, reject) =>
      exec = require('child_process').exec
      exec 'git rev-parse HEAD', (error, stdout, stderr) ->
        if error?
          reject(error)
          return
        
        sha1 = stdout.trim()

        exec 'git log -1 --format="%ct"', (error, stdout, stderr) ->
          if error?
            reject(error)
            return

          timestamp = DateUtil.timestamp(1000*parseInt(stdout.trim()))
          resolve({sha1, timestamp})

  insertSourceVersion: ->
    @getCurrentGitCommit()
    .then (gitCommit) =>
      data =
        sha1: gitCommit.sha1
        commit_date: gitCommit.timestamp
        first_deployed_at: DateUtil.timestamp()

      @app.db.select('id').from('source_version').where(sha1:data.sha1)
      .then (existing) =>
        if existing.length > 0
          return existing[0].id

        @app.db('source_version').insert(data)
        .then =>
          @app.db.select('id').from('source_version').where(sha1:data.sha1)
        .then (existing) ->
          return existing[0].id
