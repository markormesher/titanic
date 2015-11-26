##################
#  Dependencies  #
##################

path = require('path')
express = require('express')
app = express()
mongoose = require('mongoose')

#########################
#  Global declarations  #
#########################

_global = {}

##########################
#  Database connections  #
##########################

mongoose.connect('mongodb://localhost/titanic', (err, db) -> _global.db = db);

############
#  Routes  #
############

# pull routes from routes folder
routes = {
	'': require('./controllers/core'),
	'devices': require('./controllers/devices')
};

for stem, file of routes
	app.use('/' + stem, file)

# stop favicon requests
app.use('/favicon.ico', (req, res) -> res.end())

###########
#  Views  #
###########

app.set('views', path.join(__dirname, 'views'))
app.set('view engine', 'jade')
app.use(express.static(path.join(__dirname, 'assets')))

####################
#  Error handlers  #
####################

# catch 404 and forward to error handler
app.use((req, res, next) ->
	err = new Error('Not Found')
	err.status = 404
	next(err)
)

# general error handler
app.use((error, req, res, next) ->
	res.status(error.status || 500)
	res.render('core/error', {
		title: error.status + ': ' + error.message,
		message: error.message,
		status: error.status || 500,
		error: app.get('env') == 'development' ? error: null
	})
)

############
#  Start!  #
############

server = app.listen(3000)