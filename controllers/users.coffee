##################
#  Dependencies  #
##################

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
  UserManager.createUser(email, password)
)

module.exports = router
