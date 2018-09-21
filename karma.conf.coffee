karmaConfig = require('resin-config-karma')
packageJSON = require('./package.json')

module.exports = (config) ->
	karmaConfig.plugins.push(require('karma-chrome-launcher'))
	karmaConfig.browsers = ['ChromeHeadlessCustom']
	karmaConfig.customLaunchers =
		ChromeHeadlessCustom:
			base: 'ChromeHeadless'
			flags: [
				'--no-sandbox'
			]

	karmaConfig.logLevel = config.LOG_INFO
	karmaConfig.sauceLabs =
		testName: "#{packageJSON.name} v#{packageJSON.version}"
	config.set(karmaConfig)
