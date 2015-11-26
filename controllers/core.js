//////////////////
// Dependencies //
//////////////////

var express = require('express');

//////////////
// Mappings //
//////////////

var router = express.Router();

router.get('/', function (req, res) {
	res.render('core/index', {
		title: 'Titanic'
	});
});

module.exports = router;