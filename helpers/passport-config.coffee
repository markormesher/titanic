LocalPassportStrategy = require('passport-local').Strategy
crypto = require('crypto')

sha256 = (data) -> crypto.createHash('sha256').update(data).digest('hex')

users = {
	'mark': {
		password: sha256('pass')
		name: 'Mark Ormesher'
	}
	'kyle': {
		password: sha256('pass')
		name: 'Kyle Hodgetts'
	}
}

module.exports = (passport) ->
	passport.serializeUser((user, done) -> done(null, JSON.stringify(user)))

	passport.deserializeUser((user, done) -> done(null, JSON.parse(user)))

	passport.use(new LocalPassportStrategy({ passReqToCallback: true }, (req, username, password, done) ->
			if (users[username] && users[username].password == sha256(password))
				return done(null, users[username])

			req.flash('error', 'Invalid username or password!')
			return done(null, false)
		)
	)
