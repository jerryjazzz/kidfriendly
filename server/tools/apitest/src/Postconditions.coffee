
addDefaultPostconditions = (request, postconditions) ->
  # This function examines the request data, and provides a bunch of default postconditions
  # that should be true based on that.

  # (todo)

getPostconditions = (request) ->
  postconditions = {}

  # Start with defaults.
  addDefaultPostconditions(request, postconditions)

  # Copy from test data, possibly overriding defaults.
  for key, value of request.postconditions
    postconditions[key] = value

  # Add postconditions that are derived from other postconditions.
  # todo

  return postconditions

check = (request, response, report) ->
  postconditions = getPostconditions(request)

  report.debug("postconditions: " + JSON.stringify(postconditions))

  for conditionName, conditionArgs of postconditions
    func = PostconditionFunctions[conditionName]

    if not func?
      throw new Error("unknown postcondition name: #{conditionName}")

    func(response, report, conditionArgs)

PostconditionFunctions =
  # todo

module.exports = {check}
