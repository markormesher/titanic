##################
#  Dependencies  #
##################

EMAIL_REGEX = /^(([^<>()[]\.,;:s@"]+(.[^<>()[]\.,;:s@"]+)*)|(".+"))@(([[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}])|(([a-zA-Z-0-9]+.)+[a-zA-Z]{2,}))$/

express = require('express')
rfr = require('rfr')
guid = require('guid')
auth = rfr('./helpers/auth')
mysql = rfr('./helpers/mysql')
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

	# TODO: the validation code should be in the manager, not the controller, so that it can be shared by the (eventual) api
	# TODO: the createUser method should have a callback with an "err" parameter - if there's an error, create a toast and
	#       send them back to the registration page; if there's no error, redirect them to login

	email = req.body.email
	password = req.body.password
	confirmPassword = req.body.confirmPassword
	if (str.length > 0 && EMAIL_REGEX.text(email) && password == confirmPassword) # TODO: should "str" be "email"?
		UserManager.createUser(email, password)
)

module.exports = router
