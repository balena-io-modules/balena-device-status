###
Copyright 2016 Resin.io

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	 http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###

###*
# @module deviceStatus
###

find = require('lodash/find')

# This is the earliest possible year since
# Resin.io didn't exist before that.
RESIN_CREATION_YEAR = 2013

###*
# @summary Map of possible device statuses
# @type {Object}
# @public
# @constant
###
exports.status =
	CONFIGURING: 'configuring'
	IDLE: 'idle'
	OFFLINE: 'offline'
	POST_PROVISIONING: 'post-provisioning'
	UPDATING: 'updating'

###*
# @summary Array of device statuses along with their display names
# @type {Object[]}
# @public
# @constant
###
exports.statuses = [

	# The order of statuses in this list is important, as it's reflected
	# anywhere state are displayed -- currently in the device pie-chart.
	{ key: exports.status.IDLE, name: 'Online' }
	{ key: exports.status.CONFIGURING, name: 'Configuring' }
	{ key: exports.status.UPDATING, name: 'Updating' }
	{ key: exports.status.OFFLINE, name: 'Offline' }
	{ key: exports.status.POST_PROVISIONING, name: 'Post Provisioning' }

]

###*
# @summary Get status of a device
# @function
# @public
#
# @param {Object} device - device
# @fulfil {Object} - device status
# @returns {Promise}
#
# @example
# resin = require('resin-sdk')
# deviceStatus = require('resin-device-status')
#
# resin.models.device.get('9174944').then (device) ->
# 	deviceStatus.getStatus(device).then (status) ->
# 		console.log(status.key)
# 		console.log(status.name)
###
exports.getStatus = (device) ->

	# Check for post-provisioning needs to be first because the device
	# may power-cycle while in this state, therefore appearing briefly as offline
	if device.provisioning_state is 'Post-Provisioning'
		return find(exports.statuses, key: exports.status.POST_PROVISIONING)

	lastSeenDate = new Date(device.last_seen_time)
	if not device.is_online and lastSeenDate.getFullYear() < RESIN_CREATION_YEAR
		return find(exports.statuses, key: exports.status.CONFIGURING)

	if not device.is_online
		return find(exports.statuses, key: exports.status.OFFLINE)

	if device.download_progress? and device.status is 'Downloading'
		return find(exports.statuses, key: exports.status.UPDATING)

	if device.provisioning_progress?
		return find(exports.statuses, key: exports.status.CONFIGURING)

	return find(exports.statuses, key: exports.status.IDLE)
