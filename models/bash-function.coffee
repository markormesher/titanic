mongoose = require('mongoose')
module.exports = mongoose.model(
	'BashFunction',
	{
		name: {
			type: String
			required: true
		}
		code: {
			type: String
			required: true
		}
		available_internal: {
			type: Boolean
			required: true
			default: true
		}
		available_external: {
			type: Boolean
			required: true
			default: true
		}
		is_deleted: {
			type: Boolean
			required: true
			default: false
		}
	}
)
