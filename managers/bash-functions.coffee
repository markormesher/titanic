rfr = require('rfr')
guid = require('guid')
mysql = rfr('./helpers/mysql')

exp = {

	get: (query, callback) ->
		# TODO: handle for_device parameter
		delete query.for_device

		q = mysql.makeSelectQuery('BashFunction', query)
		mysql.getConnection((conn) ->
			conn.query(q[0], q[1], (err, results) ->
				if (err) then return callback(err)
				return callback(null, results)
			)
		)

	createOrUpdate: (id, func, callback) ->
		createdNew = false
		if (id == null || id == 0 || id == '0')
			# insert
			createdNew = true
			id = guid.create().value
			func.id = id
			q = mysql.makeInsertQuery('BashFunction', func)
		else
			# update
			delete func.id
			q = mysql.makeUpdateQuery('BashFunction', func, { id: id })

		mysql.getConnection((conn) ->
			conn.query(q[0], q[1], (err) ->
				if (err) then return callback(err)
				callback(null, id, createdNew)
			)
		)

	delete: (id, callback) ->
		mysql.getConnection((conn) -> conn.query('DELETE FROM BashFunction WHERE id = ?;', [id], callback))

}

module.exports = exp
