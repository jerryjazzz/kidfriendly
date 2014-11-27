module.exports = configs =
  services:
    forever:
      inbox: "tcp://127.0.0.1:3500"
    postgres:
      hostname: 'localhost'

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

# Machine-specific config (intended for AWS boxes)
machineConfig = {}
try
  machineConfig = require('/kfly/machineConfig.json')

if machineConfig?.profile == 'aws-1'
  configs.services.postgres =
    hostname: "***REMOVED***"
    user: 'dev'
    password: '***REMOVED***'
