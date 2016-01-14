mongoose = require('mongoose')
Schema = require('mongoose/lib/schema')
module.exports = mongoose.model(
	'Alias',
	{
		from_device: {
			required: true
			type: Schema.Types.ObjectId
			ref: 'Device'
		}
		to_device: {
			required: true
			type: Schema.Types.ObjectId
			ref: 'Device'
		}
	}
)
