
Promise = require('bluebird')

class TaskRunner
  taskIntervalMs: 1000

  constructor: (@app) ->
    @taskHandlers = {}

  start: ->
    @placeScraper = new PlaceScraper(@app, this)

    @app.inbox.registerCommand 'pub-test', (args, reply) =>
      @app.pub.send('pub-test: ' + args.join(' '))
      reply('ok')

    @tick()

    @app.log("task manager: started")
    return

  register: (taskName, handler) ->
    if @taskHandlers[taskName]?
      throw new Error("already have a registered task handler named: "+taskName)
    @taskHandlers[taskName] = handler

  queueTasks: (tasks) ->
    new Promise (resolve, reject) =>
      for task in tasks
        task.source_ver = @app.sourceVersion

      tasks = tasks.map(JSON.stringify)
      rpushArgs = ["tasks"].concat(tasks)
      rpushArgs.push (err, reply) =>
        if err?
          return reject(err)
        @app.pub.send("queued #{tasks.length} tasks")
        resolve()

      @app.redis.rpush.apply(@app.redis, rpushArgs)

  popNextTask: =>
    new Promise (resolve, reject) =>
      @app.redis.lpop "tasks", (err, reply) =>
        if err?
          return reject(err)

        if not reply? or reply is ''
          resolve(null)

        resolve(new Task(JSON.parse(reply)))

  tick: =>
    @popNextTask().then (task) =>
      if not task?
        setTimeout(@tick, @taskIntervalMs)
        return

      task.on 'done', @tick
      @startTask(task)

  startTask: (task) =>
    handler = @taskHandlers[task.name]
    if not handler?
      throw new Error("No task handler for task name: "+task.name)

    handler(task)

