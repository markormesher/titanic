mongoose = require('mongoose')
module.exports = mongoose.model(
	'BashShortcut',
	{
		short_command: String

		full_command: String
	}
)