##################
#  Dependencies  #
##################

express = require('express')
rfr = require('rfr')

# models
LogEvent = rfr('./models/log-event')

##############
#  Mappings  #
##############

router = express.Router()

router.get('/', (req, res) ->
	# get all log events, in descending order
	LogEvent.find({}).sort({timestamp: 'desc'}).exec((error, events) ->
		res.render('dashboard/index', {
			title: 'Dashboard'
			activePage: 'dashboard'
			eventsError: error
			events: events
		})
	)
)

module.exports = router