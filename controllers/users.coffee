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
  email = req.body.email
  password = req.body.password
	confirmPassword = req.body.confirmPassword
	if (str.length > 0 && EMAIL_REGEX.text(email) && password == confirmPassword)
  	UserManager.createUser(email, password)

)

module.exports = router
