##################
#  Dependencies  #
##################

express = require('express')

##############
#  Mappings  #
##############

router = express.Router()

router.get('/', (req, res) ->
	res.render('dashboard/index', {
		title: 'Dashboard',
		activePage: 'dashboard'
	})
)

module.exports = router