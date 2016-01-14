rfr = require('rfr')
mongoose = require('mongoose')
Device = rfr('./models/device')

module.exports = {

	# get all devices (no ID) or one device (with ID)
	get: (id, callback) ->
		# calls without ID
		if typeof id == 'function'
			callback = id
			id = null

		# build search query
		query = {is_deleted: {$in: [null, false]}}
		if id != null then query['_id'] = id

		# run query
		Device.find(query).sort({hostname: 'asc'}).exec((err, result) ->
			# errors
			if err
				callback(err, null)
				return

			# convert to objects
			for r, i in result
				result[i] = r.toObject()

			# result
			if id != null
				if result.length == 1 then callback(null, result[0]) else callback(null, null)
			else
				callback(null, result)
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