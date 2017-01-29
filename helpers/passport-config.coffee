LocalPassportStrategy = require('passport-local').Strategy
rfr = require('rfr')
auth = rfr('./helpers/auth')

users = {
	'mark': {
		password: auth.sha256('pass')
		name: 'Mark Ormesher'
	}
	'kyle': {
		password: auth.sha256('pass')
		name: 'Kyle Hodgetts'
	}
}

module.exports = (passport) ->
	passport.serializeUser((user, done) -> done(null, JSON.stringify(user)))

	passport.deserializeUser((user, done) -> done(null, JSON.parse(user)))

	passport.use(new LocalPassportStrategy({ passReqToCallback: true }, (req, username, password, done) ->
			if (users[username] && users[username].password == auth.sha256(password))
				return done(null, users[username])

			req.flash('error', 'Invalid username or password!')
			return done(null, false)
		)
	)
