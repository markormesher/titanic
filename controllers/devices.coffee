##################
#  Dependencies  #
##################

express = require('express')
rfr = require('rfr')
async = require('async')
log = rfr('./helpers/log')

# models
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
			title: 'Device List'
			activePage: 'devices'
			devices: devices
		})
	)
)

router.get('/create', (req, res) ->
	res.render('devices/edit', {
		title: 'Create Device'
		activePage: 'devices'
		device: null
	})
)

router.get('/edit/:deviceId', (req, res) ->
	# get parameters
	deviceId = req.params.deviceId

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
			title: 'Edit Device: ' + device.hostname
			activePage: 'devices'
			device: device
		})
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