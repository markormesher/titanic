rfr = require('rfr')
mongoose = require('mongoose')
Alias = rfr('./models/alias')

module.exports = {

	# get all aliases (no ID) or aliases for one device (with ID)
	get: (deviceId, callback) ->
		# calls without ID
		if typeof deviceId == 'function'
			callback = deviceId
			deviceId = null

		# build search query
		query = {}
		if deviceId != null
			query = {$or:[{from_device: deviceId}, {to_device: deviceId}]}

		# run query
		Alias.find(query).exec((err, result) ->
			# errors
			if err
				callback(err, null)
				return

			# convert to objects
			for r, i in result
				result[i] = r.toObject()

			# result
			callback(null, result)
		)

	create: (aliases, callback) ->
		Alias.create(aliases, (err) -> callback(err))

	deleteAll: (deviceId, callback) ->
		Alias.find().or([{from_device: deviceId}, {to_device: deviceId}]).remove((err) -> callback(err))

}