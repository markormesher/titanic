mongoose = require('mongoose')
module.exports = mongoose.model(
	'Device',
	{
		hostname: String

		ip_address: String

		type: {
			type: String
			validate: /(server|desktop|laptop|mobile)/
		}

		location: {
			type: String
			validate: /(internal|external)/
		}
	}
)