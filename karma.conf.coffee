packageJSON = require('./package.json')

module.exports = (config) ->
	options =
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
		concurrency: 1
		captureTimeout: 300000
		browserDisconnectTolerance: 5
		browserNoActivityTimeout: 300000

	if process.env.SAUCE_LABS
		console.info('Running in SauceLabs')

		if not process.env.SAUCE_USERNAME? or not process.env.SAUCE_ACCESS_KEY?
			console.error('Missing SAUCE_USERNAME or SAUCE_ACCESS_KEY env vars')
			process.exit(1)

		# Browsers to run on Sauce Labs
		# https://wiki.saucelabs.com/display/DOCS/Test+Configuration+Options#TestConfigurationOptions-Selenium-SpecificOptions
		options.customLaunchers =
			SL_Chrome:
				base: 'SauceLabs'
				browserName: 'chrome'

			SL_ChromeBeta:
				base: 'SauceLabs'
				browserName: 'chrome'
				version: 'beta'

			SL_ChromeDev:
				base: 'SauceLabs'
				browserName: 'chrome'
				version: 'dev'

			'SL_IE10':
				base: 'SauceLabs'
				browserName: 'internet explorer'
				platform: 'Windows 2012',
				version: '10'

			'SL_IE11':
				base: 'SauceLabs'
				browserName: 'internet explorer'
				platform: 'Windows 8.1'
				version: '11'

			SL_Edge:
				base: 'SauceLabs'
				browserName: 'microsoftedge'
				platform: 'Windows 10'
				version: '20.10240'

			SL_FireFox:
				base: 'SauceLabs'
				browserName: 'firefox'

			SL_FireFoxDev:
				base: 'SauceLabs'
				browserName: 'firefox'
				version: 'dev'

			SL_Safari7:
				base: 'SauceLabs'
				browserName: 'safari'
				platform: 'OS X 10.9'
				version: '7'

			SL_Safari8:
				base: 'SauceLabs'
				browserName: 'safari'
				platform: 'OS X 10.10'
				version: '8'

			SL_Safari9:
				base: 'SauceLabs'
				browserName: 'safari'
				platform: 'OS X 10.11'
				version: '9.0'

			'SL_Android4.1':
				base: 'SauceLabs'
				browserName: 'android'
				platform: 'Linux'
				version: '4.1'

			'SL_Android4.2':
				base: 'SauceLabs'
				browserName: 'android'
				platform: 'Linux'
				version: '4.2'

			'SL_Android4.3':
				base: 'SauceLabs'
				browserName: 'android'
				platform: 'Linux'
				version: '4.3'

			'SL_Android4.4':
				base: 'SauceLabs'
				browserName: 'android'
				platform: 'Linux'
				version: '4.4'

			'SL_Android5':
				base: 'SauceLabs'
				browserName: 'android'
				platform: 'Linux'
				version: '5.1'

			SL_iOS7:
				base: 'SauceLabs'
				browserName: 'iPhone'
				version: '7.1'

			SL_iOS8:
				base: 'SauceLabs'
				browserName: 'iPhone'
				version: '8.4'

			SL_iOS9:
				base: 'SauceLabs'
				browserName: 'iPhone'
				version: '9.1'

			SL_opera:
				base: 'SauceLabs'
				browserName: 'opera'

		options.browsers = options.browsers.concat(Object.keys(options.customLaunchers))
		options.reporters.push('saucelabs')
		options.sauceLabs =
			testName: "#{packageJSON.name} v#{packageJSON.version}"

	config.set(options)
