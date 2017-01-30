LocalPassportStrategy = require('passport-local').Strategy
rfr = require('rfr')
auth = rfr('./helpers/auth')
UserManager = rfr('./managers/users')

module.exports = (passport) ->
	passport.serializeUser((user, callback) ->
		callback(null, JSON.stringify(user)))

	passport.deserializeUser((user, callback) ->
		callback(null, JSON.parse(user)))

	passport.use(new LocalPassportStrategy(
		{
			passReqToCallback: true
		},
		(req, email, password, callback) ->
			UserManager.getUserForAuth(email, password, (err, result) ->
				if (err) then return callback(err)
				if (!result)
					req.flash('error', 'Invalid username or password!')
					return callback(null, false)
				return callback(null, result)
			)
	))
