rfr = require('rfr')
guid = require('guid')
mysql = rfr('./helpers/mysql')

exp = {

	get: (deviceId, callback) ->
		# build search query
		if deviceId == null
			query = {}
			values = []
		else
			query = "from_device = ? OR to_device = ?"
			values = [deviceId, deviceId]

		# run query
		q = mysql.makeSelectQuery('Alias', query, values)
		mysql.getConnection((conn) ->
			conn.query(q[0], q[1], (err, results) ->
				if (err) then return callback(err)
				return callback(null, results)
			)
		)

	setAliasesForDevice: (deviceId, newAliases, callback) ->
		exp.deleteAllForDevice(deviceId, (err) ->
			if (err) then return callback(err)
			mysql.getConnection((conn) ->
				for a, i in newAliases
					a.id = guid.create().value
					newAliases[i] = a
				q = mysql.makeMultiInsertQuery('Alias', ['id', 'from_device', 'to_device'], newAliases)
				conn.query(q[0], q[1], callback)
			)
		)

	deleteAllForDevice: (deviceId, callback) ->
		mysql.getConnection((conn) ->
			conn.query('DELETE FROM Alias WHERE from_device = ? OR to_device = ?;', [deviceId, deviceId], callback)
		)
}

module.exports = exp
