var mongoose = require('mongoose');
var Schema = require('mongoose/lib/schema');
var DeviceHostnameEntry = mongoose.model('DeviceHostnameEntry', {

	from_device: {
		type: Schema.Types.ObjectId,
		ref: 'Device'
	},

	to_device: {
		type: Schema.Types.ObjectId,
		ref: 'Device'
	}

});
module.exports = DeviceHostnameEntry;