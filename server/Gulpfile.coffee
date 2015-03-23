
gulp = require('gulp')
gutil = require('gulp-util')
coffee = require('gulp-coffee')
concat = require('gulp-concat')
watch = require('gulp-watch')
sourcemaps = require('gulp-sourcemaps')

coffeeFiles = ['src/DependencyCache.coffee', 'src/**/*.coffee']
watchFiles = coffeeFiles.concat(['config/*'])

gulp.task 'coffee', ->
  gulp.src(coffeeFiles)
    .pipe(sourcemaps.init({loadMaps: true}))
    .pipe(coffee())
    .pipe(concat('main.js'))
    .pipe(sourcemaps.write('.', {sourceRoot: '/src'}))
    .pipe(gulp.dest('build'))

gulp.task 'watch', ->
  gulp.watch(watchFiles, ['build'])

gulp.task 'reload-server', ['coffee'], ->
  {send} = require('./bin/Send.coffee')
  send 'forever', 'restart',
    ignoreError:true
    log: (msg) -> console.log("[forever restart] "+msg)

gulp.task('default', ['build', 'watch'])
gulp.task('build', ['coffee', 'reload-server'])
