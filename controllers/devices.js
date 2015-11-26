//////////////////
// Dependencies //
//////////////////

var express = require('express');
var rfr = require('rfr');
var constants = rfr('./helpers/constants');
var async = require('async');

// models
var Device = rfr('./models/device');
var DeviceHostnameEntry = rfr('./models/device-hostname-entry');

//////////////
// Mappings //
//////////////

var router = express.Router();

router.get('/', function (req, res) {
	// run requests in parallel
	async.parallel(
		{
			// get all devices
			devices: function (callback) {
				Device.find({}, function (err, docs) {
					callback(err, docs);
				});
			},

			// get all hostname entries
			hostnameEntries: function (callback) {
				DeviceHostnameEntry
					.find({})
					.populate('from_device to_device')
					.exec(function (err, docs) {
						callback(err, docs);
					});
			}
		},
		function (err, result) {
			// create list of devices
			var deviceList = [];
			result.devices.forEach(function (d) {
				deviceList[deviceList.length] = d;
			});

			// create list of hostname entries
			var hostnameEntryList = [];
			result.hostnameEntries.forEach(function (d) {
				hostnameEntryList[hostnameEntryList.length] = d;
			});

			// render output
			res.render('devices/index', {
				title: 'Device List',
				devices: deviceList,
				hostnameEntries: hostnameEntryList
			});
		}
	);
});

router.get('/make', function (req, res) {

	// devices
	var chuck = new Device({hostname: 'chuck', type: 'server', location: 'external', ip_address: '178.62.115.216'});
	var casey = new Device({hostname: 'casey', type: 'desktop', location: 'internal', ip_address: '192.168.0.11'});
	var sarah = new Device({hostname: 'sarah', type: 'laptop', location: 'internal', ip_address: '192.168.0.11'});

	chuck.save();
	sarah.save();
	casey.save();

	// connections
	var casey_chuck = new DeviceHostnameEntry({from_device: casey._id, to_device: chuck._id});
	var casey_sarah = new DeviceHostnameEntry({from_device: casey._id, to_device: sarah._id});
	var sarah_chuck = new DeviceHostnameEntry({from_device: sarah._id, to_device: chuck._id});
	var sarah_casey = new DeviceHostnameEntry({from_device: sarah._id, to_device: casey._id});

	casey_chuck.save();
	casey_sarah.save();
	sarah_chuck.save();
	sarah_casey.save();

	// done
	res.end();

});

router.get('/clear', function (req, res) {
	async.parallel(
		[
			function (c) {
				Device.remove({}, c);
			},

			function (c) {
				DeviceHostnameEntry.remove({}, c);
			}
		],
		function (err, docs) {
			res.end();
		}
	);
});

module.exports = router;