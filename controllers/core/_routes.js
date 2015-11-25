//////////////////
// Dependencies //
//////////////////

var express = require('express');
var indexController = require('./index-controller');

//////////////
// Mappings //
//////////////

var router = express.Router();
router.get('/', indexController.get);

router.get('/make', indexController.make);

module.exports = router;
