/*
Copyright 2016 Balena

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	 http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

/**
 * @module deviceStatus
 */

import keyBy = require('lodash/keyBy');
import maxBy = require('lodash/maxBy');
import { Device, Status } from './types';

export { Device, IHaveProgressAndStatus, Status, StatusKey } from './types';

/**
 * @summary
 * This is the earliest possible year since
 * Balena didn't exist before that.
 * @type {number}
 * @private
 * @constant
 */
const RESIN_CREATION_YEAR = 2013;

/**
 * @summary Map of possible device statuses
 * @type {Object}
 * @public
 * @constant
 */
export const status = {
	CONFIGURING: 'configuring',
	IDLE: 'idle',
	OFFLINE: 'offline',
	INACTIVE: 'inactive',
	POST_PROVISIONING: 'post-provisioning',
	UPDATING: 'updating',
} as const;

/**
 * @summary Array of device statuses along with their display names
 * @type {Object[]}
 * @public
 * @constant
 */
export const statuses: Status[] = [
	// The order of statuses in this list is important, as it's reflected
	// anywhere state are displayed -- currently in the device pie-chart.
	{ key: status.IDLE, name: 'Online' },
	{ key: status.CONFIGURING, name: 'Configuring' },
	{ key: status.UPDATING, name: 'Updating' },
	{ key: status.OFFLINE, name: 'Offline' },
	{ key: status.POST_PROVISIONING, name: 'Post Provisioning' },
	{ key: status.INACTIVE, name: 'Inactive' },
];

/**
 * @summary Map of Status objects by status key
 * @type {Object}
 * @private
 * @constant
 */
const statusesByKey = keyBy(statuses, 'key');

/**
 * @summary Get status of a device
 * @function
 * @public
 *
 * @param {Object} device - device
 * @fulfil {Object} - device status
 * @returns {Promise}
 *
 * @example
 * balena = require('balena-sdk')
 * deviceStatus = require('balena-device-status')
 *
 * balena.models.device.get('9174944').then (device) ->
 * 	deviceStatus.getStatus(device).then (status) ->
 * 		console.log(status.key)
 * 		console.log(status.name)
 */
export const getStatus = (device: Device) => {
	if (!device.is_active) {
		return statusesByKey[status.INACTIVE];
	}

	// Check for post-provisioning needs to be before the is_online checks because the device
	// may power-cycle while in this state, therefore appearing briefly as offline
	if (device.provisioning_state === 'Post-Provisioning') {
		return statusesByKey[status.POST_PROVISIONING];
	}

	const neverSeen =
		!device.last_connectivity_event ||
		new Date(device.last_connectivity_event).getFullYear() <
			RESIN_CREATION_YEAR;

	if (!device.is_online && neverSeen) {
		return statusesByKey[status.CONFIGURING];
	}

	if (!device.is_online) {
		return statusesByKey[status.OFFLINE];
	}

	if (device.download_progress != null && device.status === 'Downloading') {
		return statusesByKey[status.UPDATING];
	}

	if (device.provisioning_progress != null) {
		return statusesByKey[status.CONFIGURING];
	}

	if (device.current_services) {
		// handle SDK v10 normalized DeviceWithServiceDetails objects
		for (const serviceName of Object.keys(device.current_services || {})) {
			// We should only care about the latest image progress
			const installs = device.current_services[serviceName];
			const install = maxBy(installs, 'id');
			if (
				install &&
				install.download_progress != null &&
				install.status === 'Downloading'
			) {
				return statusesByKey[status.UPDATING];
			}
		}
	}

	return statusesByKey[status.IDLE];
};
