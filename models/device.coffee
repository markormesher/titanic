mongoose = require('mongoose')
module.exports = mongoose.model(
	'Device',
	{
		hostname: String

		type: {
			type: String
			validate: /(server|desktop|laptop|mobile)/
		}

		location: {
			type: String
			validate: /(internal|external)/
		}

		ip_address: String
	}
)