##################
#  Dependencies  #
##################

express = require('express')
moment = require('moment')
rfr = require('rfr')

##############
#  Mappings  #
##############

router = express.Router()

router.get('/', (req, res) ->
	res.render('dashboard/index', {
		_: {
			title: 'Dashboard'
			activePage: 'dashboard'
		}
	})
)

module.exports = router
