mongoose = require('mongoose')
module.exports = mongoose.model(
	'BashShortcut',
	{
		short_command: String
		full_command: String
		available_internal: {
			type: Boolean
			default: true
		}
		available_external: {
			type: Boolean
			default: true
		}
	}
)