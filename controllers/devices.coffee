##################
#  Dependencies  #
##################

express = require('express')
rfr = require('rfr')
async = require('async')

# models
Device = rfr('./models/device')
DeviceHostnameEntry = rfr('./models/device-hostname-entry')

##############
#  Mappings  #
##############

router = express.Router();

router.get('/', (req, res) ->
	# run requests in parallel
	async.parallel(
		{
			# get all devices
			devices: (callback) =>
				Device.find({}, callback)

			# get all hostname entries
			hostnameEntries: (callback) =>
				DeviceHostnameEntry
				.find({})
				.populate('from_device to_device')
				.exec(callback)
		},

		# callback
		(err, result) ->
			# create list of devices
			deviceList = [];
			result.devices.forEach((d) -> deviceList[deviceList.length] = d)

			# create list of hostname entries
			hostnameEntryList = [];
			result.hostnameEntries.forEach((e) -> hostnameEntryList[hostnameEntryList.length] = e)

			# render output
			res.render('devices/index', {
				title: 'Device List'
				activePage: 'devices'
				devices: deviceList
				hostnameEntries: hostnameEntryList
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
			res.end()
	)
)

module.exports = router;