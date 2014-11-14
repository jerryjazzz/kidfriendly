
class TestReport
  constructor: (@requestDetails) ->
    @errors = []

  _stringify: (args) ->
    args = for arg in args
      if typeof arg is 'string'
        arg
      else
        JSON.stringify(arg)
    args.join(' ')

  error: ->
    msg = @_stringify(arguments)
    console.log('[error] ', msg)
    @errors.push(msg)

  debug: ->
    msg = @_stringify(arguments)
    console.log('[debug] ', msg)

  hasErrors: ->
    @errors.length > 0

  printErrors: ->
    console.log("Test #{@name} failed with #{@errors.length} error(s): ")
    for error in @errors
      console.log(" ", error)

  @printReportList: (reports) ->
    console.log("Finished #{reports.length} request(s).")

    anyErrors = false
    for report in reports
      if report.hasErrors() > 0
        anyErrors = true
        report.printErrors()

    if not anyErrors
      console.log("No errors.")

module.exports = TestReport
