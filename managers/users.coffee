rfr = require('rfr')
guid = require('guid')
mysql = rfr('./helpers/mysql')
auth = rfr('./helpers/auth')

UserManager = {

	validateEmail: (email) ->
		regex = ///^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$///
		return regex.test(email)

	validatePassword: (password) ->
		return password.length >= 8

	getUserForAuth: (email, password, callback) ->
		mysql.getConnection((conn) ->
			[query, values] = mysql.makeSelectQuery('User', {
				email: email,
				password: auth.sha256(password)
			})
			conn.query(query, values, (err, results) ->
				if (err) then return callback(err)
				if (results && results.length == 1) then return callback(null, results[0])
				return callback(null, null)
			)
		)

	getUser: (email, callback) ->
		mysql.getConnection((conn) ->
			[query, values] = mysql.makeSelectQuery('User', { email: email })
			conn.query(query, values, (err, results) ->
				if (err) then return callback(err)
				if (results && results.length == 1) then callback(null, results[0])
				return callback(null, null)
			)
		)

	createUser: (email, password, confirmPassword, callback) ->
		errs = []

		if (!UserManager.validateEmail(email)) then errs.push('invalid email')
		if (!UserManager.validatePassword(password)) then errs.push('invalid password')
		if (password != confirmPassword) then errs.push('password mismatch')

		# don't bother checking uniqueness of an invalid email
		if (errs.indexOf('invalid email') >= 0) then return callback(errs)

		mysql.getConnection((conn) ->
			# check whether email exists
			[query, values] = mysql.makeSelectQuery('User', { email: email })
			conn.query(query, values, (err, results) ->
				if (err) then errs.push(err)
				if (results.length != 0) then errs.push('email exists')
				if (errs.length > 0) then return callback(errs)

				# create user
				[query, values] = mysql.makeInsertQuery('User', {
					id: guid.create().value
					email: email,
					password: auth.sha256(password)
				})
				conn.query(query, values, (err) ->
					if (err) then errs.push(err)
					callback(errs)
				)
			)
		)
}

module.exports = UserManager
