##################
#  Dependencies  #
##################

express = require('express')
rfr = require('rfr')
async = require('async')
mongoose = require('mongoose')
log = rfr('./helpers/log')
c = rfr('./helpers/constants')

# models
Device = rfr('./models/device')
Alias = rfr('./models/alias')

##############
#  Mappings  #
##############

router = express.Router();

router.get('/', (req, res) ->
	# get all devices
	Device.find({}).sort({hostname: 'asc'}).exec((err, devices) ->
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
	Device.find({_id: deviceId}).exec((err, device) ->
		# check for device
		if err
			req.flash('error', 'Sorry, that device couldn\'t be loaded!')
			res.writeHead(302, {Location: '/devices'})
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
		})
	)
)

router.post('/edit/:deviceId', (req, res) ->
	# get parameters
	deviceId = req.params.deviceId
	if deviceId == null || deviceId == 0 || deviceId == '0' then deviceId = false
	device = req.body

	# build create/edit query
	query = {
		_id: (if deviceId then deviceId else mongoose.Types.ObjectId())
	}

	# save in DB
	Device.update(query, device, {upsert: true}, (err) ->
		# forward to list
		if err
			log.error('Failed to update device (' + query._id + ')')
			req.flash('error', 'Sorry, something went wrong!')
		else
			if deviceId
				log.event('Edited device (' + query._id + ')')
				req.flash('success', 'Your changes were saved!')
			else
				log.event('Created device (' + query._id + ')')
				req.flash('success', 'The device <strong>' + device.hostname + '</strong> was created!')

		res.writeHead(302, {Location: '/devices'})
		res.end()
	)
)

router.get('/delete/:deviceId', (req, res) ->
	# get parameters
	deviceId = req.params.deviceId

	# delete device and aliases to the device
	async.series(
		[
			(c) -> Device.remove({_id: deviceId}, (err) -> c(err))
			(c) -> Alias.find().or([{from_device: deviceId}, {to_device: deviceId}]).remove((err) -> c(err))
		],
		(err) ->
			if err
				log.error('Failed to delete device (' + deviceId + ')')
				req.flash('error', 'Sorry, something went wrong!')
			else
				log.event('Deleted device (' + deviceId + ')')
				req.flash('info', 'Device deleted.')

			res.writeHead(302, {Location: '/devices'})
			res.end()
	)
)

module.exports = router;