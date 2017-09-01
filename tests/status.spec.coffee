m = require('mochainon')
_ = require('lodash')
status = require('../lib/status')

getDeviceMock = (overrides) ->
	return _.merge
		id: 123639
		name: 'aged-smoke'
		device_type: 'beaglebone-black'
		uuid: 'fdaa8ac34273568975e3d7031da1ae8f21b857a667dd7fcfbfca551808397d'
		status: null
		is_online: true
		last_seen_time: '2014-01-01T00:00:00.000Z'
		public_address: ''
		supervisor_version: null
		supervisor_release: null
		provisioning_progress: null
		provisioning_state: null
		download_progress: null
		application_name: 'BeagleTest'
	, overrides

describe 'Status', ->

	describe '.status', ->

		it 'should be a plain object', ->
			m.chai.expect(_.isPlainObject(status.status)).to.be.true

		it 'should not be empty', ->
			m.chai.expect(_.isEmpty(status.status)).to.be.false

	describe '.statuses', ->

		it 'should be an array', ->
			m.chai.expect(status.statuses).to.be.an.instanceof(Array)

		it 'should not be empty', ->
			m.chai.expect(_.isEmpty(status.statuses)).to.be.false

		it 'should contain valid key and name properties', ->
			for deviceStatus in status.statuses
				m.chai.expect(deviceStatus.key).to.be.a('string')
				m.chai.expect(_.isEmpty(deviceStatus.key)).to.be.false
				m.chai.expect(deviceStatus.name).to.be.a('string')
				m.chai.expect(_.isEmpty(deviceStatus.name)).to.be.false

	describe '.getStatus()', ->

		it 'should return POST_PROVISIONING if provisioning_state is Post-Provisioning', ->
			device = getDeviceMock(provisioning_state: 'Post-Provisioning')
			m.chai.expect(status.getStatus(device)).to.deep.equal
				key: 'post-provisioning'
				name: 'Post Provisioning'

		it 'should return CONFIGURING if is_online is false and the device was not seen', ->
			device = getDeviceMock
				is_online: false
				last_seen_time: null

			m.chai.expect(status.getStatus(device)).to.deep.equal
				key: 'configuring'
				name: 'Configuring'

		it 'should return CONFIGURING if is_online is false and the device was seen before 2013', ->
			device = getDeviceMock
				is_online: false
				last_seen_time: '1970-01-01T00:00:00.000Z'

			m.chai.expect(status.getStatus(device)).to.deep.equal
				key: 'configuring'
				name: 'Configuring'

		it 'should return OFFLINE if is_online is false and the device was seen after 2013', ->
			device = getDeviceMock
				is_online: false
				last_seen_time: '2014-01-01T00:00:00.000Z'

			m.chai.expect(status.getStatus(device)).to.deep.equal
				key: 'offline'
				name: 'Offline'

		it 'should return OFFLINE if there is a download_progress and status is Downloading and is_online is false', ->
			device = getDeviceMock
				is_online: false
				download_progress: 45
				status: 'Downloading'

			m.chai.expect(status.getStatus(device)).to.deep.equal
				key: 'offline'
				name: 'Offline'

		it 'should return UPDATING if there is a download_progress and status is Downloading and is_online is true', ->
			device = getDeviceMock
				is_online: true
				download_progress: 45
				status: 'Downloading'

			m.chai.expect(status.getStatus(device)).to.deep.equal
				key: 'updating'
				name: 'Updating'

		it 'should return CONFIGURING if there is a provisioning_progress', ->
			device = getDeviceMock
				provisioning_progress: 50

			m.chai.expect(status.getStatus(device)).to.deep.equal
				key: 'configuring'
				name: 'Configuring'

		it 'should return IDLE if is_online is true and the device was not seen', ->
			device = getDeviceMock
				is_online: true
				last_seen_time: null

			m.chai.expect(status.getStatus(device)).to.deep.equal
				key: 'idle'
				name: 'Online'

		it 'should return IDLE if is_online is true and the device was seen after 2013', ->
			device = getDeviceMock
				is_online: true
				last_seen_time: '2014-01-01T00:00:00.000Z'

			m.chai.expect(status.getStatus(device)).to.deep.equal
				key: 'idle'
				name: 'Online'

		it 'should return IDLE if is_online is true and the device was seen after 2013 and there is no download_progress', ->
			device = getDeviceMock
				is_online: true
				last_seen_time: '2014-01-01T00:00:00.000Z'
				download_progress: null

			m.chai.expect(status.getStatus(device)).to.deep.equal
				key: 'idle'
				name: 'Online'
