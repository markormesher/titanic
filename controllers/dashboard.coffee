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
	LogEvent.find({}).sort({timestamp: 'desc'}).exec((err, events) ->

		# convert date format
		events = events.map(
			(e) -> {
				type: e.type
				message: e.message
				timestamp: moment(e.timestamp).format('YYYY-MM-DD HH:mm:ss')
			}
		)

		res.render('dashboard/index', {
			_: {
				title: 'Dashboard'
				activePage: 'dashboard'
			}
			eventsError: err
			events: events
		})
	)
)

module.exports = router
