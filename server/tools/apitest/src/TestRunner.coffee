
Promise = require('bluebird')
fs = require('fs')
TestReport = require('./TestReport')

getUrl = (requestDetails) ->
  url = "http://#{process.host}#{requestDetails.path}"
  if requestDetails.params?
    url += "?" + ("#{k}=#{v}" for k,v of requestDetails.params).join(',')
  return url

runOneRequest = (requestDetails) -> new Promise (resolve, reject) ->
  report = new TestReport(requestDetails)

  url = getUrl(requestDetails)
  headers =
    'content-type': 'application/json'

  if requestDetails.body?
    method = 'post'
    body = JSON.stringify(requestDetails.body)
  else
    method = 'get'
    body = null

  report.debug("requesting url = #{url}")

  require('request') {method, url, headers, body}, (error, response) ->
    if error?
      report.error(''+error)
      report.error('Response:', response.body)
      return reject(report)

    try
      body = JSON.parse(response.body)
    catch e
      report.error("Response didn't parse as JSON: ", response.body)
      return reject(report)

    if response.statusCode != 200
      report.debug('Non-200 status code: ' + response.statusCode)
      report.debug('Response:', body)
      return reject(report)

    report.debug('Response: ', body)

    if process.saveResult
      path = "response.json"
      fs.writeFileSync(path, JSON.stringify(body, null, '\t'))
      report.debug("Saved response to #{path}")

    #validateResponse(test, body, report)

    resolve(report)

validateResponse = (req, response, report) ->
  require('./Postconditions').check(req, response, report)

runRequestList = (requestList) ->
  tests = for request in requestList
    {request}

  Promise.each tests, (test) ->
    runOneRequest(test.request)
    .then (report) ->
      test.report = report

  .then ->
    (test.report for test in tests)

module.exports = {runOneRequest, runRequestList}
