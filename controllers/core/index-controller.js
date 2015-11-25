var rfr = require('rfr');
var constants = rfr('./helpers/constants');
var Device = rfr('./models/device');

module.exports = {

	get: function (req, res) {
		// get all devices
		Device.find({}, function(err, devices) {
			var deviceMap = [];
			devices.forEach(function (d) {
				deviceMap[deviceMap.length] = d;
			});

			res.render('core/index', {
				title: 'Titanic Device List',
				devices: deviceMap
			});
		});
	},

	make: function(req, res) {
		var sarah = new Device({hostname: 'sarah', type: 'laptop', location: 'internal', ip_address: '192.168.0.11'});
		sarah.save(function (err) {
			if (err) console.log(err);
		});
		res.end();
	}

};
