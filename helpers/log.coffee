rfr = require('rfr')
LogEvent = rfr('./models/log-event')

module.exports = {

	# create a new log entry
	event: (message, error = false) ->
		new LogEvent({
			message: message
			type: if error then 'error' else 'normal'
		}).save()

	# create a new error log entry
	error: (message) -> event(message, true)

}