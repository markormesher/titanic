##################
#  Dependencies  #
##################

express = require('express')
rfr = require('rfr')

# models
Device = rfr('./models/device')

##############
#  Mappings  #
##############

router = express.Router();

router.get('/', (req, res) ->
	# get all devices
	Device.find({}).sort({hostname: 'asc'}).exec((err, devices) ->
		# render output
		res.render('hosts-file-aliases/index', {
			_: {
				title: 'Hosts File Aliases'
				activePage: 'hosts-file-aliases'
			}
			devices: devices
		})
	)
)

module.exports = router;