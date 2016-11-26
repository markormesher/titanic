rfr = require('rfr')
mongoose = require('mongoose')
Alias = rfr('./models/alias')

module.exports = {

	# get all aliases (no ID) or aliases for one device (with ID)
	get: (query, callback) ->
		# calls without ID
		if typeof query == 'function'
			callback = query
			query = null

		# build search query
		if query == null
			query = {}
		else if typeof query == 'string'
			query = {$or: [{from_device: query}, {to_device: query}]}

		# run query
		Alias.find(query).exec((err, result) ->
			if err
				callback(err, null)
				return

			for r, i in result
				result[i] = r.toObject()

			callback(null, result)
		)

	create: (aliases, callback) ->
		Alias.create(aliases, (err) -> callback(err))

	deleteAll: (deviceId, callback) ->
		Alias.find().or([{from_device: deviceId}, {to_device: deviceId}]).remove((err) -> callback(err))

}
