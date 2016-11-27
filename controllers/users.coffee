##################
#  Dependencies  #
##################

express = require('express')
rfr = require('rfr')
guid = require('guid')
auth = rfr('helpers/auth')
mysql = rfr('helpers/mysql')
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
  id = guid.create().value
  email = req.body.email
  password = req.body.password
  hash = auth.sha256(password)
  mysql.getConnection((conn) ->
    query = "INSERT INTO USER(id, email, password) VALUES(?)"
  )



)

module.exports = router
