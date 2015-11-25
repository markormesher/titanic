var rfr = require('rfr');
var constants = rfr('./helpers/constants');

module.exports = {

	get: function (req, res) {
		res.render('core/index', {
			title: 'Titanic'
		});
	}

};
