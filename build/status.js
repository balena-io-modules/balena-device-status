
/*
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
 */

/**
 * @module deviceStatus
 */
var RESIN_CREATION_YEAR, find, maxBy,
  hasProp = {}.hasOwnProperty;

find = require('lodash/find');

maxBy = require('lodash/maxBy');

RESIN_CREATION_YEAR = 2013;


/**
 * @summary Map of possible device statuses
 * @type {Object}
 * @public
 * @constant
 */

exports.status = {
  CONFIGURING: 'configuring',
  IDLE: 'idle',
  OFFLINE: 'offline',
  INACTIVE: 'inactive',
  POST_PROVISIONING: 'post-provisioning',
  UPDATING: 'updating'
};


/**
 * @summary Array of device statuses along with their display names
 * @type {Object[]}
 * @public
 * @constant
 */

exports.statuses = [
  {
    key: exports.status.IDLE,
    name: 'Online'
  }, {
    key: exports.status.CONFIGURING,
    name: 'Configuring'
  }, {
    key: exports.status.UPDATING,
    name: 'Updating'
  }, {
    key: exports.status.OFFLINE,
    name: 'Offline'
  }, {
    key: exports.status.POST_PROVISIONING,
    name: 'Post Provisioning'
  }, {
    key: exports.status.INACTIVE,
    name: 'Inactive'
  }
];


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
 * resin = require('resin-sdk')
 * deviceStatus = require('resin-device-status')
 *
 * resin.models.device.get('9174944').then (device) ->
 * 	deviceStatus.getStatus(device).then (status) ->
 * 		console.log(status.key)
 * 		console.log(status.name)
 */

exports.getStatus = function(device) {
  var install, installs, lastSeenDate, neverSeen, ref, serviceName;
  if (!device.is_active) {
    return find(exports.statuses, {
      key: exports.status.INACTIVE
    });
  }
  if (device.provisioning_state === 'Post-Provisioning') {
    return find(exports.statuses, {
      key: exports.status.POST_PROVISIONING
    });
  }
  lastSeenDate = new Date(device.last_connectivity_event);
  neverSeen = lastSeenDate.getFullYear() < RESIN_CREATION_YEAR;
  if (!device.is_online && neverSeen) {
    return find(exports.statuses, {
      key: exports.status.CONFIGURING
    });
  }
  if (!device.is_online) {
    return find(exports.statuses, {
      key: exports.status.OFFLINE
    });
  }
  if ((device.download_progress != null) && device.status === 'Downloading') {
    return find(exports.statuses, {
      key: exports.status.UPDATING
    });
  }
  if (device.provisioning_progress != null) {
    return find(exports.statuses, {
      key: exports.status.CONFIGURING
    });
  }
  if (device.current_services) {
    ref = device.current_services;
    for (serviceName in ref) {
      if (!hasProp.call(ref, serviceName)) continue;
      installs = ref[serviceName];
      install = maxBy(installs, 'id');
      if (install && (install.download_progress != null) && install.status === 'Downloading') {
        return find(exports.statuses, {
          key: exports.status.UPDATING
        });
      }
    }
  }
  return find(exports.statuses, {
    key: exports.status.IDLE
  });
};
