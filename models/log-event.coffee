mongoose = require('mongoose')
module.exports = mongoose.model(
	'LogEvent',
	{
		timestamp: {
			type: Date
			default: Date.now
		}
		type: {
			type: String
			validate: /(normal|error)/
			default: 'normal'
		}
		message: String
	}
)
