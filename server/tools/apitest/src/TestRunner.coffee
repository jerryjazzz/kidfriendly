
Promise = require('bluebird')
fs = require('fs')

getUrl = (test) ->
  url = "http://#{test.host}#{test.path}"
  if test.params?
    url += "?" + ("#{k}=#{v}" for k,v of test.params).join(',')
  return url

runTest = (test, report) -> new Promise (resolve, reject) ->
  existingProject = null

  url = getUrl(test)
  headers =
    'content-type': 'application/json'

  if test.body?
    method = 'post'
    body = JSON.stringify(test.body)
  else
    method = 'get'
    body = null

  report.debug("requesting url = #{url}")

  require('request') {method, url, headers, body}, (error, response, responseBody) ->
    if error?
      report.error(''+error)
      report.error('Response: ' + responseBody)
      return resolve(report)

    if response? and response.statusCode != 200
      report.debug('Non-200 status code: ' + response.statusCode)
      report.debug('Response: ' + responseBody)
      return resolve(report)

    try
      response = JSON.parse(responseBody)
    catch e
      report.error("Response didn't parse as JSON: ", responseBody)
      return resolve(report)

    console.log('Response: ', response)

    if test.save
      path = "response.json"
      fs.writeFileSync(path, JSON.stringify(response, null, '\t'))
      report.debug("Saved response to #{path}")

    validateResponse(test, response, report)

    resolve(report)

validateResponse = (req, response, report) ->
  require('./Postconditions').check(req, response, report)

module.exports = {runTest}
