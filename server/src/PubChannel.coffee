
PubChannel =
  setup: (app) ->
    appConfig = app.config.appConfig
    if not appConfig.pub?
      app.log("nanomsg pub: not started (config)")
      return

    pub = app.pub = require('nanomsg').socket('pub')
    pub.bind(appConfig.pub)
    app.log("nanomsg pub: broadcasting on "+appConfig.pub)
    return
