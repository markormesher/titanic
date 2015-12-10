##################
#  Dependencies  #
##################

express = require('express')
moment = require('moment')
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

		# convert date format
		events = events.map(
			(e) -> {
				type: e.type
				message: e.message
				timestamp: moment(e.timestamp).format('YYYY-MM-DD HH:mm:ss')
			}
		)

		# render
		res.render('dashboard/index', {
			_: {
				title: 'Dashboard'
				activePage: 'dashboard'
			}
			eventsError: error
			events: events
		})
	)
)

module.exports = router