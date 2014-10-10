
Promise = require('bluebird')

class TaskManager
  taskIntervalMs: 1000

  constructor: (@app) ->
    @taskHandlers = {}

  start: ->
    @placeScraper = new PlaceScraper(@app, this)

    @app.inbox.registerCommand 'pub-test', (args, reply) =>
      @app.pub.send('pub-test: ' + args.join(' '))
      reply('ok')

    @tick()

    console.log("task manager: started")
    return

  register: (taskName, handler) ->
    if @taskHandlers[taskName]?
      throw new Error("already have a registered task handler named: "+taskName)
    @taskHandlers[taskName] = handler

  queueTasks: (tasks) ->
    new Promise (resolve, reject) =>
      console.log("tasks: ", tasks)
      tasks = tasks.map(JSON.stringify)
      console.log('pushing tasks: ', tasks)
      @app.redis.rpush "tasks", tasks, (err, reply) =>
        if err?
          return reject(err)
        @app.pub.send("queued #{tasks.length} tasks")
        resolve()

  peekNextTask: =>
    new Promise (resolve, reject) =>
      @app.redis.lrange "tasks", 0,0, (err, reply) =>
        console.log('peek tasks: ', reply)
        if err?
          return reject(err)
        resolve(reply?[0])

  tick: =>
    @peekNextTask().then (task) =>
      if not task?
        setTimeout(@tick, @taskIntervalMs)
        return

      console.log('next task is: ', JSON.stringify(task))
      @startTask(task)
        .on 'finish', @tick

  startTask: (task) =>
    handler = @taskHandlers[task.name]
    if not handler?
      throw new Error("No task handler for task name: "+task.name)

    handler(task)

