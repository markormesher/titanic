rfr = require('rfr')
mongoose = require('mongoose')
async = require('async')
BashShortcut = rfr('./models/bash-shortcut')
DeviceManager = rfr('./managers/devices')

module.exports = {

	# get an array of shortcuts matching the given query (can be {} to get all shortcuts)
	get: (query, callback) ->
		async.waterfall(
			[
				# start with basic non-deleted search query
				(c) ->
					c(null, {is_deleted: {$in: [null, false]}})

				# is there an ID to add?
				(searchQuery, c) ->
					if query.hasOwnProperty('id') && query.id
						searchQuery._id = query.id
					c(null, searchQuery)

				# is there a device id or name passed?
				(searchQuery, c) ->
					if (query.hasOwnProperty('for_device') && query.for_device) || (query.hasOwnProperty('for_device_name') && query.for_device_name)
						# build search query
						q = {}
						if (query.hasOwnProperty('for_device'))
							q.id = query.for_device
						else
							q.name = query.for_device_name

						# find device
						DeviceManager.get(q, (err, devices) ->
							# errors
							if err || !devices || !devices.length then return c(err)

							# add internal/external restrictions
							device = devices[0]
							if device.location == 'internal'
								searchQuery['available_internal'] = true
							else
								searchQuery['available_external'] = true

							# continue
							c(null, searchQuery)
						)
					else
						c(null, searchQuery)

				# run query
				(searchQuery, c) ->
					BashShortcut.find(searchQuery).sort({short_command: 'asc'}).exec((err, result) ->
						if err then return c(err)

						for r, i in result
							result[i] = r.toObject()

						callback(null, result)
					)
			],
			() -> callback('Could not load shortcuts')
		)

	createOrUpdate: (id, shortcut, callback) ->
		# build query to locate new/target item
		if id == null || id == 0 || id == '0' then id = false
		query = {
			_id: (if id then id else mongoose.Types.ObjectId())
		}

		BashShortcut.update(query, shortcut, {upsert: true}, (err) -> callback(err, query._id, !id))

	delete: (id, callback) ->
		BashShortcut.update({_id: id}, {is_deleted: true}, {}, (err) -> callback(err))

}
