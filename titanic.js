//////////////////
// Dependencies //
//////////////////

var path = require('path');
var express = require('express');
var app = express();

////////////
// Routes //
////////////

// pull routes from routes folder
var routes = {
	'': require('./controllers/core/_routes')
};
for (var stem in routes) {
	//noinspection JSUnfilteredForInLoop
	app.use('/' + stem, routes[stem]);
}

// stop favicon requests
app.use('/favicon.ico', function (req, res) {
	res.end();
});

///////////
// Views //
///////////

app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');
app.use(express.static(path.join(__dirname, 'assets')));

////////////////////
// Error handlers //
////////////////////

// catch 404 and forward to error handler
app.use(function (req, res, next) {
	var err = new Error('Not Found');
	err.status = 404;
	next(err);
});

// error handler
app.use(function (error, req, res, next) {
	res.status(error.status || 500);
	res.render('core/error', {
		title: error.status + ': ' + error.message,
		message: error.message,
		status: error.status || 500,
		error: app.get('env') === 'development' ? error : null
	});
});

////////////
// Start! //
////////////

var server = app.listen(3000);
