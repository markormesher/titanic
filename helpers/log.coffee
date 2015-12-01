rfr = require('rfr')
LogEvent = rfr('./models/log-event')

module.exports = {

	# create a new log entry
	event: (message) ->
		new LogEvent({
			message: message
			type: 'normal'
		}).save()

	# create a new error log entry
	error: (message) ->
		new LogEvent({
			message: message
			type: 'error'
		}).save();

}