gulp = require("gulp")
gutil = require("gulp-util")
replace = require('gulp-replace-task')
args    = require('yargs').argv
fs = require('fs')
bower = require("bower")
runSequence = require('run-sequence')
concat = require("gulp-concat")
sass = require("gulp-sass")
minifyCss = require("gulp-minify-css")
rename = require("gulp-rename")
sh = require("shelljs")
coffee = require("gulp-coffee")
sourcemaps = require("gulp-sourcemaps")
karma = require("karma").server
singleRun = true
paths =
  sass: ["./scss/**/*.scss"]
  coffee: ["./src/**/*.coffee"]
  assets: [
    "./img/**/*.{png,jpg}"
    "./templates/**/*.html"
    "./index.html"
  ]

gulp.task "default", (done) ->
  runSequence ["assets", "sass", "coffee"], "replace", "test", ->

gulp.task "sass", (done) ->
  gulp.src("./scss/ionic.app.scss").pipe(sass()).pipe(gulp.dest("./www/css/")).pipe(minifyCss(keepSpecialComments: 0)).pipe(rename(extname: ".min.css")).pipe(gulp.dest("./www/css/")).on "end", done
  return

gulp.task "assets", (done) ->
  gulp.src(paths.assets,
    base: "."
  ).pipe(gulp.dest("./www")).on "end", done
  return

gulp.task "coffee", [], (done) ->
  gulp.src(paths.coffee).pipe(sourcemaps.init()).pipe(coffee().on("error", gutil.log)).pipe(sourcemaps.write()).pipe(gulp.dest("./www/js")).on "end", done
  return

gulp.task "watch", ->
  gulp.watch paths.sass.concat(paths.coffee.concat(paths.assets)), ->
    runSequence(["assets", "sass", "coffee"], "replace", (done)->)

  return

gulp.task "install", ["git-check"], ->
  bower.commands.install().on "log", (data) ->
    gutil.log "bower", gutil.colors.cyan(data.id), data.message
    return


gulp.task "tdd", ["default"], (done) ->
  karma.start
    configFile: __dirname + "/karma.conf.coffee"
    singleRun: false
  , done
  return

gulp.task "test", (done) ->
  karma.start
    configFile: __dirname + "/karma.conf.coffee"
    singleRun: false
  , done
  return

gulp.task "git-check", (done) ->
  unless sh.which("git")
    console.log "  " + gutil.colors.red("Git is not installed."), "\n  Git, the version control system, is required to download Ionic.", "\n  Download git here:", gutil.colors.cyan("http://git-scm.com/downloads") + ".", "\n  Once git is installed, run '" + gutil.colors.cyan("gulp install") + "' again."
    process.exit
  done()
  return


gulp.task 'replace', ()  ->
  env = args.env || 'production'

  filename = "#{env}.json"
  settings = JSON.parse(fs.readFileSync('./config/' + filename, 'utf8'))
  gulp.src('www/js/shared/KFConstants.js')
    .pipe replace
      patterns: [
        match: 'kfUri',
        replacement: settings.kfUri
        ]
    .pipe(gulp.dest('www/js/shared'))