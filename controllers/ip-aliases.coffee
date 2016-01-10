##################
#  Dependencies  #
##################

express = require('express')
rfr = require('rfr')
c = rfr('./helpers/constants')
utils = rfr('./helpers/utils')

# models
Device = rfr('./models/device')

##############
#  Mappings  #
##############

router = express.Router();

router.get('/', (req, res) ->
	# get all devices
	Device.find({}).sort({hostname: 'asc'}).exec((err, devices) ->
		# add connections array to all
		for d, i in devices
			d = d.toObject()
			d.hostsFileEntries = []
			devices[i] = d

		# render output
		res.render('ip-aliases/index', {
			_: {
				title: 'IP Aliases'
				activePage: 'ip-aliases'
			}
			devices: devices
			deviceTypes: c.DEVICE_TYPES
		})
	)
)

router.get('/edit/:deviceId', (req, res) ->
	# get parameters
	deviceId = req.params.deviceId

	# find device
	Device.find({_id: deviceId}).exec((err, device) ->
		# check for device
		if (err || !device)
			req.flash('error', 'Sorry, that device couldn\'t be loaded!')
			res.writeHead(302, {Location: '/ip-aliases'})
			res.end()
			return
		else
			device = device[0]

		# render output
		res.render('ip-aliases/edit', {
			_: {
				title: 'Manage IP Aliases for ' + device.hostname
				activePage: 'ip-aliases'
			}
			device: device
		})
	)
)

module.exports = router;