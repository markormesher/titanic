##################
#  Dependencies  #
##################

express = require('express')
rfr = require('rfr')
async = require('async')
log = rfr('./helpers/log')
c = rfr('./helpers/constants')
utils = rfr('./helpers/utils')

# models
mongoose = require('mongoose')
Device = rfr('./models/device')
DeviceHostnameEntry = rfr('./models/device-hostname-entry')

##############
#  Mappings  #
##############

router = express.Router();

router.get('/', (req, res) ->
	# get parameters
	status = req.query.status

	# get all devices
	Device.find({}).sort({hostname: 'asc'}).exec((err, devices) ->
		# render output
		res.render('devices/index', {
			_: {
				title: 'Device List'
				activePage: 'devices'
			}
			status: status
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
		device: null
		deviceTypes: utils.objectToArray(c.DEVICE_TYPES)
	})
)

router.get('/edit/:deviceId', (req, res) ->
	# get parameters
	deviceId = req.params.deviceId
	status = req.query.status

	# find device
	Device.find({_id: deviceId}).exec((err, device) ->
		# check for device
		if (err)
			res.writeHead(302, {Location: '/devices?status=error'})
			res.end()
			return
		else
			device = device[0]

		# render output
		res.render('devices/edit', {
			_: {
				title: 'Edit Device: ' + device.hostname
				activePage: 'devices'
			}
			device: device
			deviceTypes: c.DEVICE_TYPES
			status: status
		})
	)
)

router.post('/edit/:deviceId', (req, res) ->
	# get parameters
	deviceId = req.params.deviceId
	if (deviceId == null || deviceId == 0 || deviceId == '0') then deviceId = false
	device = req.body

	# build create/edit query
	query = {
		_id: (if deviceId then deviceId else mongoose.Types.ObjectId())
	}

	# save in DB
	Device.update(query, device, {upsert: true}, (err) ->
		if (err) then throw err

		# log
		log.event((if deviceId then 'Edited' else 'Created') + ' device (' + query._id + ')')

		# forward to edit page
		status = if err then 'error' else (if deviceId then 'saved' else 'created')
		res.writeHead(302, {
			Location: '/devices?status=' + status
		})
		res.end()
	)
)

router.get('/delete/:deviceId', (req, res) ->
	# get parameters
	deviceId = req.params.deviceId

	# delete device
	Device.remove({_id: deviceId}, (err) ->
		# log
		log.event('Deleted device (' + deviceId + ')')

		res.writeHead(302, {
			Location: '/devices?status=deleted'
		})
		res.json(deviceId)
	)
)

module.exports = router;