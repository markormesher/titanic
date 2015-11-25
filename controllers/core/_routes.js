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

module.exports = router;
