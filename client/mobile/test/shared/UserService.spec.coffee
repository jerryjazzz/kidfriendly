'use strict'
describe 'UserService', ->
  userService = {}
  beforeEach ->
    module 'Mobile'
    module 'kf.shared'

    module ($provide) ->
      $provide.decorator 'eventBus', (mockEventBus) ->
        eventBus = mockEventBus
        return mockEventBus

      $provide.value 'projectService', {validate: ->}
      $provide.value 'commandFactory', mockCommandFactory
      return

    inject (_userService_) ->
      userService = _userService_