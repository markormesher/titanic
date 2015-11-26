###################
#   Dependencies  #
###################

express = require('express')

##############
#  Mappings  #
##############

router = express.Router()

router.get('/', (req, res) ->
	res.render('core/index', {
		title: 'Titanic Coffee'
	})
)

module.exports = router