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
		res.render('hosts-file-aliases/index', {
			_: {
				title: 'Hosts File Aliases'
				activePage: 'hosts-file-aliases'
			}
			devices: devices
			deviceTypes: c.DEVICE_TYPES
		})
	)
)

module.exports = router;