##################
#  Dependencies  #
##################

express = require('express')
rfr = require('rfr')
async = require('async')
c = rfr('./helpers/constants')
log = rfr('./helpers/log')

# models
Device = rfr('./models/device')
Alias = rfr('./models/alias')

##############
#  Mappings  #
##############

router = express.Router();

router.get('/', (req, res) ->
	# get all devices and aliases
	async.parallel(
		{
			devices: (c) -> Device.find({}).sort({hostname: 'asc'}).exec((err, devices) -> c(err, devices))
			aliases: (c) -> Alias.find({}).exec((err, aliases) -> c(err, aliases))
		},
		(err, results) ->
			# count aliases
			outboundAliases = {};
			inboundAliases = {};
			for d in results.devices
				outboundAliases[d._id] = 0
				inboundAliases[d._id] = 0
			for a in results.aliases
				++outboundAliases[a.from_device]
				++inboundAliases[a.to_device]

			# convert devices to objects with count
			devices = []
			for d in results.devices
				d = d.toObject()
				d.outboundAliases = outboundAliases[d._id]
				d.inboundAliases = inboundAliases[d._id]
				devices.push(d)

			# render output
			res.render('aliases/index', {
				_: {
					title: 'Aliases'
					activePage: 'aliases'
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
			aliases: (c) -> Alias.find().or([{from_device: deviceId}, {to_device: deviceId}]).exec((err, aliases) -> c(err, aliases))
		},
		(err, results) ->
			# read results
			{devices, device, aliases} = results

			# check for device
			if err || !device
				req.flash('error', 'Sorry, that device couldn\'t be loaded!')
				res.writeHead(302, {Location: '/aliases'})
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
			for a in aliases
				aliasMap[a.from_device][a.to_device] = true

			# rule: aliases are not possible in some situations
			aliasPossible = (from, to) ->
				from = from.toObject()
				to = to.toObject()

				# a -> a not allowed
				if (from._id.toString() == to._id.toString()) then return false

				# ext -> int not allowed
				if (from.location == 'external' && to.location == 'internal') then return false

				# everything else is okay
				return true

			# create possible inbound and outbound device lists, based on rule above
			outboundDevices = []
			inboundDevices = []
			for d in devices
				if aliasPossible(device, d) then outboundDevices.push(d)
				if aliasPossible(d, device) then inboundDevices.push(d)

			# render output
			res.render('aliases/edit', {
				_: {
					title: 'Manage Aliases: ' + device.hostname
					activePage: 'aliases'
				}
				outboundDevices: outboundDevices
				inboundDevices: inboundDevices
				device: device
				aliasMap: aliasMap
			})
	)
)

router.post('/edit/:deviceId', (req, res) ->
	# get parameters
	deviceId = req.params.deviceId
	aliases = req.body

	# build new aliases
	newAliases = []
	for k, v of aliases
		if k.substr(0, 4) == 'out_' && v == '1'
			newAliases.push({from_device: deviceId, to_device: k.substr(4)})
		if k.substr(0, 3) == 'in_' && v == '1'
			newAliases.push({from_device: k.substr(3), to_device: deviceId})

	# update aliases
	async.series(
		[
			(c) -> Alias.find().or([{from_device: deviceId}, {to_device: deviceId}]).remove((err) -> c(err))
			(c) -> Alias.create(newAliases, (err) -> c(err))
		],
		(err) ->
			# send back to list
			if err
				log.error('Failed to update aliases (' + deviceId + ')')
				req.flash('error', 'Sorry, something went wrong!')
			else
				log.event('Edited aliases (' + deviceId + ')')
				req.flash('success', 'Your changes were saved!')

			res.writeHead(302, {Location: '/aliases'})
			res.end()
	)
)

module.exports = router;