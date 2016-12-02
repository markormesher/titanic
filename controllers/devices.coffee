##################
#  Dependencies  #
##################

express = require('express')
rfr = require('rfr')
async = require('async')
c = rfr('./helpers/constants')
auth = rfr('./helpers/auth')

# managers
DeviceManager = rfr('./managers/devices')

##############
#  Mappings  #
##############

router = express.Router();

router.get('/', auth.checkAndRefuse, (req, res) ->
	DeviceManager.get({}, (err, devices) ->
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

router.get('/create', auth.checkAndRefuse, (req, res) ->
	res.render('devices/edit', {
		_: {
			title: 'Create Device'
			activePage: 'devices'
		}
		deviceTypes: c.DEVICE_TYPES
	})
)

router.get('/edit/:deviceId', auth.checkAndRefuse, (req, res) ->
	deviceId = req.params.deviceId

	# find device
	DeviceManager.get({ id: deviceId,}, (err, devices) ->
		if err or devices == []
			req.flash('error', 'Sorry, that device couldn\'t be loaded!')
			res.writeHead(302, {Location: '/devices'})
			res.end()
			return

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

router.post('/edit/:deviceId', auth.checkAndRefuse, (req, res) ->
	deviceId = req.params.deviceId
	device = req.body

	DeviceManager.createOrUpdate(deviceId, device, (err, deviceId, createdNew) ->
		if err
			req.flash('error', 'Sorry, something went wrong!')
		else
			if createdNew
				req.flash('success', 'The device <strong>' + device.hostname + '</strong> was created!')
			else
				req.flash('success', 'Your changes were saved!')

		res.writeHead(302, {Location: '/devices'})
		res.end()
	)
)

router.get('/delete/:deviceId', auth.checkAndRefuse, (req, res) ->
	deviceId = req.params.deviceId

	DeviceManager.delete(deviceId, (err) ->
		if err
			req.flash('error', 'Sorry, something went wrong!')
		else
			req.flash('info', 'Device deleted.')

		res.writeHead(302, {Location: '/devices'})
		res.end()
	)
)

module.exports = router;
