
class TestReport
  constructor: (@name) ->
    @errors = []

  error: (msg) ->
    console.log('[error] ', msg)
    @errors.push(msg)

  debug: (msg) ->
    console.log('[debug] ', msg)

  hasErrors: ->
    @errors.length > 0

  printErrors: ->
    console.log("Test #{@name} failed with #{@errors.length} error(s): ")
    for error in @errors
      console.log(" ", error)

  @printReportList: (reports) ->
    console.log("Finished #{reports.length} test(s).")

    anyErrors = false
    for report in reports
      if report.hasErrors() > 0
        anyErrors = true
        report.printErrors()

    if not anyErrors
      console.log("No errors.")

module.exports = TestReport
