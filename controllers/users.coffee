##################
#  Dependencies  #
##################

express = require('express')
rfr = require('rfr')
UserManager = rfr('./managers/users')

##############
#  Mappings  #
##############

router = express.Router();

router.get('/register', (req, res) ->
	res.render('users/register', {
		_: {
			title: 'Register'
			activePage: 'register'
		}
	})
)

router.post('/register', (req, res) ->
	email = req.body['email']
	password = req.body['password']
	confirmPassword = req.body['confirmPassword']

	UserManager.createUser(email, password, confirmPassword, (errs) ->
		if (errs.length > 0)
			req.flash('error', 'Sorry, that didn\'t work - please try again.')
			res.render('users/register', {
				_: {
					title: 'Register'
					activePage: 'register'
				}
				email: email
				errors: errs
			})
		else
			req.flash('success', 'Your account has been created!')
			res.redirect('/auth/login')
	)
)

module.exports = router
