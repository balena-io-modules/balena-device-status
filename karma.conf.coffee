getKarmaConfig = require('resin-config-karma')
packageJSON = require('./package.json')

module.exports = (config) ->
	karmaConfig = getKarmaConfig(packageJSON)
	config.set(karmaConfig)
