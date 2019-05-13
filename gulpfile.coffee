gulp = require('gulp')
mocha = require('gulp-mocha')

OPTIONS =
	files:
		coffee: [ 'tests/**/*.spec.coffee' ]
		tests: 'tests/**/*.spec.coffee'

gulp.task 'test', ->
	gulp.src(OPTIONS.files.tests, read: false)
		.pipe(mocha({
			reporter: 'min'
		}))
