var mongoose = require('mongoose');
mongoose.connect('mongodb://localhost/titanic');

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

