##################
#  Dependencies  #
##################

express = require('express')
rfr = require('rfr')
async = require('async')
auth = rfr('./helpers/auth')

# managers
DeviceManager = rfr('./managers/devices')
AliasManager = rfr('./managers/aliases')
BashFunctionManager = rfr('./managers/bash-functions')
BashShortcutManager = rfr('./managers/bash-shortcuts')

##############
#  Mappings  #
##############

router = express.Router();

router.get('/', auth.checkAndRefuse, (req, res) ->
	res.json({
		message: 'Titanic API'
		endpoints: [
			'/aliases'
			'/aliases/{hostname}'
			'/bash-functions'
			'/bash-shortcuts'
			'/devices'
		]
	})
)

router.get('/aliases', auth.checkAndRefuse, (req, res) ->
	async.waterfall(
		[
			# get devices
			(c) -> DeviceManager.get({}, (err, devices) ->
				if (err) then return c(err, null)

				deviceMap = {}
				for d in devices
					deviceMap[d.id] = d

				c(err, deviceMap)
			)

			# get alias list
			(deviceMap, c) -> AliasManager.get(null, (err, aliases) ->
				if (err) then return c(err, null)

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

router.get('/aliases/:fromHostName', auth.checkAndRefuse, (req, res) ->
	fromHostName = req.params.fromHostName

	async.waterfall(
		[
			# get devices
			(c) -> DeviceManager.get({}, (err, devices) ->
				if (err) then return c(err, null)

				deviceMap = {}
				for d in devices
					deviceMap[d.id] = d

				c(err, deviceMap)
			)

			# get device ID matching the host name parameter
			(deviceMap, c) ->
				for id, d of deviceMap
					if d.hostname == fromHostName then return c(null, deviceMap, id)
				c('no device')

			# get alias list
			(deviceMap, fromDeviceId, c) -> AliasManager.get({ from_device: fromDeviceId }, (err, aliases) ->
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
				if req.query.format and req.query.format == 'bash'
					# format as bash script
					output = ''
					for hostname, ip of result
						output += ip + ' ' + hostname + '\n'
					res.send(output)
					res.end();
				else
					# return as JSON
					res.json(result)
	)
)

router.get('/bash-functions', auth.checkAndRefuse, (req, res) ->
	BashFunctionManager.get(req.query, (err, functions) ->
		if err
			res.status(500)
			res.send('ERROR')
			res.end()
		else
			if req.query.format and req.query.format == 'bash'
				# format as bash script
				output = ''
				for f in functions
					output += 'function ' + f.name + ' {\n' + f.code + '\n}\n'
				res.send(output)
				res.end();
			else
				# return as JSON
				res.json(functions)
	)
)

router.get('/bash-shortcuts', auth.checkAndRefuse, (req, res) ->
	BashShortcutManager.get(req.query, (err, shortcuts) ->
		if err
			res.status(500)
			res.send('ERROR')
			res.end()
		else
			if req.query.format and req.query.format == 'bash'
				# format as bash script
				output = ''
				for s in shortcuts
					output += 'alias ' + s.short_command + '=\'' + s.full_command + '\'\n'
				res.send(output)
				res.end();
			else
				# return as JSON
				res.json(shortcuts)
	)
)

router.get('/devices', auth.checkAndRefuse, (req, res) ->
	DeviceManager.get(req.query, (err, devices) ->
		if err
			res.status(500)
			res.send('ERROR')
			res.end()
		else
			res.json(devices)
	)
)

module.exports = router;
