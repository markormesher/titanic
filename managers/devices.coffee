rfr = require('rfr')
guid = require('guid')
mysql = rfr('./helpers/mysql')

exp = {

	get: (query, callback) ->
		q = mysql.makeSelectQuery('Device', query)
		mysql.getConnection((conn) ->
			conn.query(q[0], q[1], (err, results) ->
				if (err) then return callback(err)
				return callback(null, results)
			)
		)

	createOrUpdate: (id, device, callback) ->
		createdNew = false
		if (id == null || id == 0 || id == '0')
			# insert
			createdNew = true
			id = guid.create().value
			device.id = id
			q = mysql.makeInsertQuery('Device', device)
		else
			# update
			delete device.id
			q = mysql.makeUpdateQuery('Device', device, { id: id })

		mysql.getConnection((conn) ->
			conn.query(q[0], q[1], (err) ->
				if (err) then return callback(err)
				callback(null, id, createdNew)
			)
		)

	delete: (id, callback) ->
		mysql.getConnection((conn) -> conn.query('DELETE FROM Device WHERE id = ?;', [id], callback))

}

module.exports = exp
