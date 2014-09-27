bluebird = require('bluebird')

SourceUtil =
  getCurrentGitCommit: ->
    new bluebird (resolve, reject) =>
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
