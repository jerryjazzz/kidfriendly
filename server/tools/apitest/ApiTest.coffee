#!/usr/bin/env coffee

Promise = require('bluebird')
argv = require('yargs').argv
TestReport = require('./src/TestReport')
TestRunner = require('./src/TestRunner')

host =
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

tests = for filename in args
  runTestFile(filename)

Promise.all(tests)
  .then (reports) ->
    TestReport.printReportList(reports)
