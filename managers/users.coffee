rfr = require('rfr')
guid = require('guid')
mysql = rfr('./helpers/mysql')
auth = rfr('./helpers/auth')
module.exports = {

	get: (email, callback) ->
		mysql.getConnection((conn) ->
			[query, values] = mysql.makeSelectQuery('User', { email: email })
			conn.query(query, values, (err, results) ->
				if (err) then return callback(err)
				if (results.length == 1) then return results[0]
				return null
			)
		)

	# TODO: check that user does not exist
	createUser: (email, password) ->
		mysql.getConnection((conn) ->
			[query, values] = mysql.makeInsertQuery('User', {
				id: guid.create().value
				email: email,
				password: auth.sha256(password)
			})
			conn.query(query, values, (err, results) ->
				if (err) then return callback(err)
				console.log(results);
			)
		)
}
