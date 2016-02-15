##################
#  Dependencies  #
##################

express = require('express')
rfr = require('rfr')
async = require('async')
log = rfr('./helpers/log')
c = rfr('./helpers/constants')

# managers
DeviceManager = rfr('./managers/devices')

##############
#  Mappings  #
##############

router = express.Router();

router.get('/', (req, res) ->
	# get all devices
	DeviceManager.get({}, (err, devices) ->
		# render output
		res.render('devices/index', {
			_: {
				title: 'Devices'
				activePage: 'devices'
			}
			devices: devices
			deviceTypes: c.DEVICE_TYPES
		})
	)
)

router.get('/create', (req, res) ->
	res.render('devices/edit', {
		_: {
			title: 'Create Device'
			activePage: 'devices'
		}
		deviceTypes: c.DEVICE_TYPES
	})
)

router.get('/edit/:deviceId', (req, res) ->
	# get parameters
	deviceId = req.params.deviceId

	# find device
	DeviceManager.get({id: deviceId}, (err, devices) ->
		# check for device
		if err or devices == []
			req.flash('error', 'Sorry, that device couldn\'t be loaded!')
			res.writeHead(302, {Location: '/devices'})
			res.end()
			return

		# render output
		device = devices[0]
		res.render('devices/edit', {
			_: {
				title: 'Edit Device: ' + device.hostname
				activePage: 'devices'
			}
			device: device
			deviceTypes: c.DEVICE_TYPES
		})
	)
)

router.post('/edit/:deviceId', (req, res) ->
	# get parameters
	deviceId = req.params.deviceId
	device = req.body

	# save in DB
	DeviceManager.createOrUpdate(deviceId, device, (err, deviceId, createdNew) ->
		# forward to list
		if err
			log.error('Failed to update device ' + deviceId)
			req.flash('error', 'Sorry, something went wrong!')
		else
			if createdNew
				log.event('Created device ' + deviceId)
				req.flash('success', 'The device <strong>' + device.hostname + '</strong> was created!')
			else
				log.event('Edited device ' + deviceId)
				req.flash('success', 'Your changes were saved!')

		res.writeHead(302, {Location: '/devices'})
		res.end()
	)
)

router.get('/delete/:deviceId', (req, res) ->
	# get parameters
	deviceId = req.params.deviceId

	# delete device
	DeviceManager.delete(deviceId, (err) ->
		if err
			log.error('Failed to delete device ' + deviceId)
			req.flash('error', 'Sorry, something went wrong!')
		else
			log.event('Deleted device ' + deviceId)
			req.flash('info', 'Device deleted.')

		res.writeHead(302, {Location: '/devices'})
		res.end()
	)
)

module.exports = router;