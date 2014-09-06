

gulp = require('gulp')
gutil = require('gulp-util')
tar = require('gulp-tar')
gzip = require('gulp-gzip')
coffee = require('gulp-coffee')
concat = require('gulp-concat')

coffeeFiles = ['src/**/*.coffee']

gulp.task 'coffee', ->
  gulp.src(coffeeFiles)
    .pipe(concat('kfly_server.coffee'))
    .pipe(coffee())
    .pipe(gulp.dest('build'))

gulp.task('default', ['build', 'watch'])
gulp.task('build', ['coffee'])
