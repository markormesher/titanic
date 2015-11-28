##################
#  Dependencies  #
##################

express = require('express')

##############
#  Mappings  #
##############

router = express.Router()

router.get('/', (req, res) ->
	res.writeHead(301, {Location: "/dashboard"})
	res.end()
)

module.exports = router