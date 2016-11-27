rfr = require('rfr')
guid = require('guid')
mysql = rfr('./helpers/mysql')

exp = {

	get: (query, callback) ->
		# TODO: handle for_device parameter
		delete query.for_device

		q = mysql.makeSelectQuery('BashShortcut', { is_deleted: 0 })
		mysql.getConnection((conn) ->
			conn.query(q[0], q[1], (err, results) ->
				if (err) then return callback(err)
				return callback(null, results)
			)
		)

	createOrUpdate: (id, shortcut, callback) ->
		console.log(shortcut)
		createdNew = false
		if (id == null || id == 0 || id == '0')
			# insert
			createdNew = true
			id = guid.create().value
			shortcut.id = id
			q = mysql.makeInsertQuery('BashShortcut', shortcut)
		else
			# update
			delete shortcut.id
			q = mysql.makeUpdateQuery('BashShortcut', shortcut, { id: id })

		mysql.getConnection((conn) ->
			conn.query(q[0], q[1], (err) ->
				if (err) then return callback(err)
				callback(null, id, createdNew)
			)
		)

	delete: (id, callback) ->
		exp.createOrUpdate(id, { is_deleted: 1 }, callback)

}

module.exports = exp
