##################
#  Dependencies  #
##################

express = require('express')
rfr = require('rfr')
async = require('async')

# models
Device = rfr('./models/device')
Alias = rfr('./models/alias')
BashShortcut = rfr('./models/bash-shortcut')

##############
#  Mappings  #
##############

router = express.Router();

router.get('/', (req, res) ->
	res.json({
		message: 'Titanic API'
		endpoints: [
			'/aliases'
			'/aliases/{hostname}'
			'/bash-shortcuts'
			'/bash-shortcuts/external'
			'/bash-shortcuts/internal'
			'/devices'
		]
	})
)

router.get('/devices', (req, res) ->
	# get devices
	Device.find().exec((err, devices) ->
		if err
			res.status(500)
			res.end();
		else
			out = []
			for d in devices
				d = d.toObject()
				delete(d._id)
				out.push(d)
			res.json(out)
	)
)

router.get('/aliases', (req, res) ->
	async.waterfall(
		[
			# get devices
			(c) -> Device.find().exec((err, devices) ->
				deviceMap = {}
				for d in devices
					d = d.toObject()
					deviceMap[d._id] = d
				c(err, deviceMap)
			)

			# get alias list
			(deviceMap, c) -> Alias.find().exec((err, aliases) ->
				out = {}
				for a in aliases
					fromHostName = deviceMap[a.from_device].hostname
					if !out[fromHostName] then out[fromHostName] = {}
					toHostName = deviceMap[a.to_device].hostname
					toIp = deviceMap[a.to_device].ip_address
					out[fromHostName][toHostName] = toIp

				c(err, out)
			)
		],
		(err, result) ->
			if err
				res.status(500)
				res.end()
			else
				res.json(result)
	)
)

router.get('/aliases/:fromHostName', (req, res) ->
	# get parameters
	fromHostName = req.params.fromHostName

	async.waterfall(
		[
			# get devices
			(c) -> Device.find().exec((err, devices) ->
				deviceMap = {}
				for d in devices
					d = d.toObject()
					deviceMap[d._id] = d
				c(err, deviceMap)
			)

			# get device ID matching the host name parameter
			(deviceMap, c) ->
				for id, d of deviceMap
					if d.hostname == fromHostName
						c(null, deviceMap, id)
						return
				c('no device')

			# get alias list
			(deviceMap, fromDeviceId, c) -> Alias.find({from_device: fromDeviceId}).exec((err, aliases) ->
				out = {}
				for a in aliases
					toHostName = deviceMap[a.to_device].hostname
					toIp = deviceMap[a.to_device].ip_address
					out[toHostName] = toIp

				c(err, out)
			)
		],
		(err, result) ->
			if err
				res.status(if err == 'no device' then 404 else 500)
				res.end()
			else
				res.json(result)
	)
)

router.get('/bash-shortcuts/:query?', (req, res) ->
	# get parameters
	query = req.params.query

	# build search
	search = null
	if (!query) then search = {}
	if (query == 'internal') then search = {available_internal: true}
	if (query == 'external') then search = {available_external: true}
	if search == null
		res.status(404)
		res.end();

	# get devices
	BashShortcut.find(search).exec((err, shortcuts) ->
		if err
			res.status(500)
			res.end();
		else
			out = []
			for s in shortcuts
				s = s.toObject()
				delete(s._id)
				out.push(s)
			res.json(out)
	)
)

module.exports = router;