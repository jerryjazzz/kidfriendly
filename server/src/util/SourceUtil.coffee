Promise = require('bluebird')

class SourceUtil
  constructor: ->
    @app = depend('App')

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

          time = timestamp(1000*parseInt(stdout.trim()))
          resolve({sha1, time})

  insertSourceVersion: ->
    data = {}
    @getCurrentGitCommit()
    .then (gitCommit) =>
      data =
        sha1: gitCommit.sha1
        commit_date: gitCommit.timestamp
        first_deployed_at: timestamp()
        feature_list: JSON.stringify(@app.config.currentFeatures)

      @app.db.select('id').from('source_version').where(sha1:data.sha1)
    .then (rows) =>
      if rows.length != 0
        rows[0].id
      else
        @performInsert(data)

  performInsert: (data) ->
    currentSourceId = null

    @app.db('source_version').insert(data)
    .then =>
      @app.db.select('id').from('source_version').where(sha1:data.sha1)
    .then (rows) =>
      # Update the feature list
      currentSourceId = parseInt(rows[0].id)
      prevSourceId = currentSourceId - 1
      @app.db.select('feature_list').from('source_version').where(id:prevSourceId)
    .then (rows) =>
      prevFeatureList = @parseList(rows[0].feature_list)

      for delta in @featureListDelta(prevFeatureList, @app.config.currentFeatures)
        @app.db('source_feature_delta').insert
          source_ver: currentSourceId
          affected_feature: delta.affected_feature
          change_type: delta.change_type
    .all()
    .then ->
      currentSourceId

  featureListDelta: (prev, current) ->
    out = []
    for feature in prev
      if not (feature in current)
        @app.log("Feature was removed: " + feature)
        out.push(affected_feature: feature, change_type: 'remove')
    for feature in current
      if not (feature in prev)
        @app.log("Feature was added: " + feature)
        out.push(affected_feature: feature, change_type: 'add')
    out

  parseList: (jsonStr) ->
    if jsonStr == "" or not jsonStr?
      return []
    else
      return JSON.parse(jsonStr)

provide.class(SourceUtil)
