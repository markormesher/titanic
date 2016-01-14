rfr = require('rfr')
mongoose = require('mongoose')
BashShortcut = rfr('./models/bash-shortcut')

module.exports = {

	# get all shortcuts (no ID) or one shortcut (with ID)
	get: (id, callback) ->
		# calls without ID
		if typeof id == 'function'
			callback = id
			id = null

		# build search query
		query = {is_deleted: {$in: [null, false]}}
		if id != null then query['_id'] = id

		# run query
		BashShortcut.find(query).sort({short_command: 'asc'}).exec((err, result) ->
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

	createOrUpdate: (id, shortcut, callback) ->
		# build query to locate new/target item
		if id == null || id == 0 || id == '0' then id = false
		query = {
			_id: (if id then id else mongoose.Types.ObjectId())
		}

		# update/insert
		BashShortcut.update(query, shortcut, {upsert: true}, (err) -> callback(err, query._id, !id))

	delete: (id, callback) ->
		BashShortcut.update({_id: id}, {is_deleted: true}, {}, (err) -> callback(err))

}