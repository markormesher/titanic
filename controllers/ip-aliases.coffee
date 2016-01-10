##################
#  Dependencies  #
##################

express = require('express')
rfr = require('rfr')
async = require('async')
c = rfr('./helpers/constants')
utils = rfr('./helpers/utils')

# models
Device = rfr('./models/device')
IpAlias = rfr('./models/ip-alias')

##############
#  Mappings  #
##############

router = express.Router();

router.get('/', (req, res) ->
	# get all devices and aliases
	async.parallel(
		{
			devices: (c) -> Device.find({}).sort({hostname: 'asc'}).exec((err, devices) -> c(err, devices))
			ipAliases: (c) -> IpAlias.find({}).exec((err, ipAliases) -> c(err, ipAliases))
		},
		(err, results) ->
			# count ip aliases and convert results to objects
			ipAliases = {};
			for d in results.devices
				ipAliases[d._id] = 0
			for a in results.ipAliases
				++ipAliases[a.from_device]

			# convert devices to objects with count
			devices = []
			for d in results.devices
				d = d.toObject()
				d.ipAliases = ipAliases[d._id]
				devices.push(d)

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

	# find device and aliases
	async.parallel(
		{
			devices: (c) -> Device.find({}).exec((err, devices) -> c(err, devices))
			device: (c) -> Device.find({_id: deviceId}).exec((err, devices) -> c(err, devices))
			ipAliases: (c) -> IpAlias.find().or([{from_device: deviceId}, {to_device: deviceId}]).exec((err, ipAliases) -> c(err, ipAliases))
		},
		(err, results) ->
			# read results
			{devices, device, ipAliases} = results

			# check for device
			if (err || !device)
				req.flash('error', 'Sorry, that device couldn\'t be loaded!')
				res.writeHead(302, {Location: '/ip-aliases'})
				res.end()
				return
			else
				device = device[0]

			# convert aliases to true/false 2D array
			aliasMap = {}
			for d1 in devices
				aliasMap[d1._id] = {}
				for d2 in devices
					aliasMap[d1._id][d2._id] = false;
			for a in ipAliases
				aliasMap[a.from_device][a.to_device] = true

			# render output
			res.render('ip-aliases/edit', {
				_: {
					title: 'Manage IP Aliases for ' + device.hostname
					activePage: 'ip-aliases'
				}
				devices: devices
				device: device
				aliasMap: aliasMap
			})
	)
)

module.exports = router;