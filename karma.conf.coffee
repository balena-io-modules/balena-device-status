module.exports = (config) ->
	config.set
		basePath: ''
		frameworks: [ 'browserify', 'mocha' ]
		files: [
			'lib/*.coffee'
			'tests/*.spec.coffee'
		]
		exclude: []
		preprocessors:
			'**/*.coffee': [ 'browserify' ]
		browserify:
			debug: true
			transform: [ 'coffeeify' ]
			extensions: [ '.js', '.coffee' ]
		reporters: [ 'progress' ]
		port: 9876
		colors: true
		logLevel: config.LOG_INFO
		autoWatch: false
		browsers: [ 'PhantomJS' ]
		singleRun: true
		concurrency: Infinity
