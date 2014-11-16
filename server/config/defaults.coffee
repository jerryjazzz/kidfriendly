configs =
  services:
    forever:
      inbox: "tcp://127.0.0.1:3500"
    mysql:
      hostname: 'localhost'
      user: 'web'

  apps:
    web:
      inbox: "tcp://127.0.0.1:3501"
      express:
        "port": 3000
      
      roles:
        dbMigration: {}

    worker:
      inbox: "tcp://127.0.0.1:3502"
      pub: "tcp://127.0.0.1:3503"
      redis: {}
      taskRunner: {}

# AWS settings
###
if process.env.AWS_PATH?
  configs.services.mysql.hostname = "***REMOVED***"
###

module.exports = configs
