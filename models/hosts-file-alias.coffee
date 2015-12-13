mongoose = require('mongoose')
Schema = require('mongoose/lib/schema')
module.exports = mongoose.model(
	'HostsFileAlias',
	{
		from_device: {
			type: Schema.Types.ObjectId
			ref: 'Device'
		}

		to_device: {
			type: Schema.Types.ObjectId
			ref: 'Device'
		}
	}
)