mongoose = require('mongoose')
module.exports = mongoose.model(
	'Device',
	{
		hostname: String
		ip_address: {
			type: String
			required: true
		}
		type: {
			type: String
			required: true
			validate: /(server|desktop|laptop|mobile|other)/
		}
		location: {
			type: String
			required: true
			validate: /(internal|external)/
		}
		is_deleted: {
			type: Boolean
			required: true
			default: false
		}
	}
)
