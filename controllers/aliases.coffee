##################
#  Dependencies  #
##################

express = require('express')
rfr = require('rfr')
async = require('async')
c = rfr('./helpers/constants')
log = rfr('./helpers/log')
auth = rfr('./helpers/auth')

# managers
DeviceManager = rfr('./managers/devices')
AliasManager = rfr('./managers/aliases')

##############
#  Mappings  #
##############

router = express.Router();

router.get('/', auth.checkAndRefuse, (req, res) ->
	async.parallel(
		{
			devices: (c) -> DeviceManager.get({}, c)
			aliases: (c) -> AliasManager.get(c)
		},
		(err, results) ->
			# count aliases
			outboundAliases = {};
			inboundAliases = {};
			for d in results.devices
				outboundAliases[d.id] = 0
				inboundAliases[d.id] = 0
			for a in results.aliases
				++outboundAliases[a.from_device]
				++inboundAliases[a.to_device]

			# convert devices to objects with count
			devices = []
			for d in results.devices
				d.outboundAliases = outboundAliases[d.id]
				d.inboundAliases = inboundAliases[d.id]
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

router.get('/edit/:deviceId', auth.checkAndRefuse, (req, res) ->
	deviceId = req.params.deviceId

	async.parallel(
		{
			devices: (c) -> DeviceManager.get({}, c)
			device: (c) -> DeviceManager.get({ id: deviceId }, c)
			aliases: (c) -> AliasManager.get(deviceId, c)
		},
		(err, results) ->
			{devices, device, aliases} = results

			# check for device
			if err or !device
				req.flash('error', 'Sorry, that device\'s aliases couldn\'t be loaded!')
				res.writeHead(302, { Location: '/aliases' })
				res.end()
				return
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

router.post('/edit/:deviceId', auth.checkAndRefuse, (req, res) ->
	deviceId = req.params.deviceId
	aliases = req.body

	# build new aliases
	newAliases = []
	for k, v of aliases
		if k.substr(0, 4) == 'out_' && v == '1'
			newAliases.push({ from_device: deviceId, to_device: k.substr(4) })
		if k.substr(0, 3) == 'in_' && v == '1'
			newAliases.push({ from_device: k.substr(3), to_device: deviceId })

	async.series(
		[
			(c) -> AliasManager.deleteAll(deviceId, c)
			(c) -> AliasManager.create(newAliases, c)
		],
		(err) ->
			# send back to list
			if err
				log.error('Failed to update aliases for device ' + deviceId)
				req.flash('error', 'Sorry, something went wrong!')
			else
				log.event('Edited aliases for device ' + deviceId)
				req.flash('success', 'Your changes were saved!')

			res.writeHead(302, { Location: '/aliases' })
			res.end()
	)
)

module.exports = router;
