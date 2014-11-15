#!/usr/bin/env coffee

Promise = require('bluebird')
argv = require('yargs').argv
TestReport = require('./src/TestReport')
TestRunner = require('./src/TestRunner')

process.saveResponse = argv.save?

process.host =
  switch argv.env
    when 'local'
      'localhost:3000'
    when 'prod'
      'kidfriendlyreviews.com'
    else
      throw new Error("no --env argument?")

runTestFile = (filename) ->
  report = new TestReport(filename)
  testDetails = require("./#{filename}")
  testDetails.sourceFilename = filename
  testDetails.host = host
  testDetails.save = argv.save?
  TestRunner.runTest(testDetails, report)

args = argv._

if args.length == 0
  console.log("no command or test?")
  process.exit(1)

requests = for filename in args
  details = require("./#{filename}")
  if details.requestList?
    TestRunner.runRequestList(details.requestList)
  else
    runTestFile(filename)

flatten = (list) ->
  return [].concat.apply([], list)

Promise.all(requests)
  .then (reports) ->
    reports = flatten(reports)
    TestReport.printReportList(reports)
  .catch(console.log)
