rfr = require('rfr')
mongoose = require('mongoose')
async = require('async')
Device = rfr('./models/device')

module.exports = {

	# get an array of devices matching the given query (can be {} to get all devices)
	get: (query, callback) ->
		# build search query, then execute it
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

				# is there a name to add?
				(searchQuery, c) ->
					if query.hasOwnProperty('name') && query.name
						searchQuery.hostname = query.name
					c(null, searchQuery)

				# run query
				(searchQuery, c) ->
					Device.find(searchQuery).sort({hostname: 'asc'}).exec((err, result) ->
						# errors
						if err then return c(err)

						# convert to objects
						for r, i in result
							result[i] = r.toObject()

						# result
						callback(null, result)
					)
			],
			() -> callback('Could not load devices')
		)

	createOrUpdate: (id, device, callback) ->
		# build query to locate new/target item
		if id == null || id == 0 || id == '0' then id = false
		query = {
			_id: (if id then id else mongoose.Types.ObjectId())
		}

		# update/insert
		Device.update(query, device, {upsert: true}, (err) -> callback(err, query._id, !id))

	delete: (id, callback) ->
		Device.update({_id: id}, {is_deleted: true}, {}, (err) -> callback(err))

}