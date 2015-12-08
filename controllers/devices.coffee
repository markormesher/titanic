##################
#  Dependencies  #
##################

express = require('express')
rfr = require('rfr')
async = require('async')
log = rfr('./helpers/log')

# models
mongoose = require('mongoose')
Device = rfr('./models/device')
DeviceHostnameEntry = rfr('./models/device-hostname-entry')

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
				title: 'Device List'
				activePage: 'devices'
			}
			devices: devices
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
			res.writeHead(301, {Location: '/devices'})
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
		if (err)
			throw err

		# forward to edit page
		status = if err then 'error' else (if deviceId then 'saved' else 'created')
		res.writeHead(301, {
			Location: '/devices/edit/' + query._id + '?status=' + status
		})
		res.end()
	)
)

router.get('/make', (req, res) ->
# devices
	chuck = new Device({hostname: 'chuck', type: 'server', location: 'external', ip_address: '178.62.115.216'});
	casey = new Device({hostname: 'casey', type: 'desktop', location: 'internal', ip_address: '192.168.0.11'});
	sarah = new Device({hostname: 'sarah', type: 'laptop', location: 'internal', ip_address: '192.168.0.11'});

	chuck.save()
	sarah.save()
	casey.save()

	# connections
	casey_chuck = new DeviceHostnameEntry({from_device: casey._id, to_device: chuck._id})
	casey_sarah = new DeviceHostnameEntry({from_device: casey._id, to_device: sarah._id})
	sarah_chuck = new DeviceHostnameEntry({from_device: sarah._id, to_device: chuck._id})
	sarah_casey = new DeviceHostnameEntry({from_device: sarah._id, to_device: casey._id})

	casey_chuck.save()
	casey_sarah.save()
	sarah_chuck.save()
	sarah_casey.save()

	## demo log, for now - REMOVE LATER
	log.event("Made devices")

	## done
	res.end()
);

router.get('/clear', (req, res) ->
# run requests in parallel
	async.parallel(
		[
# remove devices
			(callback) -> Device.remove({}, callback)

# remove hostname entries
			(callback) -> DeviceHostnameEntry.remove({}, callback)
		],

# callback
		(err, docs) ->
## demo log, for now - REMOVE LATER
			log.error("Cleared devices")

			res.end()
	)
)

module.exports = router;