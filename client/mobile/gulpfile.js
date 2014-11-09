var gulp = require('gulp');
var gutil = require('gulp-util');
var bower = require('bower');
var concat = require('gulp-concat');
var sass = require('gulp-sass');
var minifyCss = require('gulp-minify-css');
var rename = require('gulp-rename');
var sh = require('shelljs');
var coffee = require('gulp-coffee');
var sourcemaps = require('gulp-sourcemaps');
var karma = require('karma').server;

var paths = {
    sass: ['./scss/**/*.scss'],
    coffee: ['./src/**/*.coffee'],
    assets: ['./img/**/*.{png, jpg}', './templates/**/*.html', './index.html'],
};

gulp.task('default', ['assets', 'sass', 'coffee']);

gulp.task('sass', function(done) {
    gulp.src('./scss/ionic.app.scss')
        .pipe(sass())
        .pipe(gulp.dest('./www/css/'))
        .pipe(minifyCss({
            keepSpecialComments: 0
        }))
        .pipe(rename({ extname: '.min.css' }))
        .pipe(gulp.dest('./www/css/'))
        .on('end', done);
});

gulp.task('assets', function(done) {
  gulp.src(paths.assets, {base:'.'})
    .pipe(gulp.dest("./www")).on('end', done);
});

gulp.task('coffee', ['test'], function(done) {
    gulp.src(paths.coffee)
        .pipe(sourcemaps.init())
        .pipe(coffee().on('error', gutil.log))
        .pipe(sourcemaps.write())
        .pipe(gulp.dest('./www/js'))
        .on('end', done)
});

gulp.task('watch', function() {
    gulp.watch(paths.sass.concat(paths.coffee.concat(paths.assets)), ['default']);
});


gulp.task('install', ['git-check'], function() {
    return bower.commands.install()
        .on('log', function(data) {
            gutil.log('bower', gutil.colors.cyan(data.id), data.message);
        });
});

gulp.task('tdd', function (done) {
    karma.start({
        configFile: __dirname + '/karma.conf.coffee',
        singleRun: false
    }, done);
});

gulp.task('test', function (done) {
    karma.start({
        configFile: __dirname + '/karma.conf.coffee',
        singleRun: true
    }, done);
});


gulp.task('git-check', function(done) {
    if (!sh.which('git')) {
        console.log(
                '  ' + gutil.colors.red('Git is not installed.'),
            '\n  Git, the version control system, is required to download Ionic.',
            '\n  Download git here:', gutil.colors.cyan('http://git-scm.com/downloads') + '.',
                '\n  Once git is installed, run \'' + gutil.colors.cyan('gulp install') + '\' again.'
        );
        process.exit(1);
    }
    done();
});