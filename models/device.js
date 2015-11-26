var mongoose = require('mongoose');
var Device = mongoose.model('Device', {

	hostname: String,

	type: {
		type: String,
		validate: /(server|desktop|laptop|mobile)/
	},

	location: {
		type: String,
		validate: /(internal|external)/
	},

	ip_address: String

});
module.exports = Device;