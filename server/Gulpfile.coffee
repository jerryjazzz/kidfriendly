

gulp = require('gulp')
gutil = require('gulp-util')
tar = require('gulp-tar')
gzip = require('gulp-gzip')
coffee = require('gulp-coffee')
concat = require('gulp-concat')
watch = require('gulp-watch')

coffeeFiles = ['src/**/*.coffee']

gulp.task 'coffee', ->
  gulp.src(coffeeFiles)
    .pipe(concat('kfly_server.coffee'))
    .pipe(coffee())
    .pipe(gulp.dest('build'))

gulp.task 'watch', ->
  gulp.watch(coffeeFiles, ['build', 'reload-server'])

gulp.task 'reload-server', ->
  {send} = require('./bin/Send.coffee')
  send 'forever', 'restart',
    ignoreError:true
    log: (msg) -> console.log("[forever restart] "+msg)

gulp.task('default', ['build', 'watch'])
gulp.task('build', ['coffee'])
