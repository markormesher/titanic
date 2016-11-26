rfr = require('rfr')
LogEvent = rfr('./models/log-event')

module.exports = {

	event: (message) ->
		new LogEvent({
			message: message
			type: 'normal'
		}).save()

	error: (message) ->
		new LogEvent({
			message: message
			type: 'error'
		}).save();

}
