##################
#  Dependencies  #
##################

path = require('path')
express = require('express')
mongoose = require('mongoose')
bodyParser = require('body-parser')
coffeeMiddleware = require('coffee-middleware')
sassMiddleware = require('node-sass-middleware')
cookieParser = require('cookie-parser')
session = require('express-session')
flash = require('express-flash')
rfr = require('rfr')
log = rfr('./helpers/log')
c = rfr('./helpers/constants')
pJson = rfr('./package.json')

##########################
#  Database connections  #
##########################

mongoose.connect('mongodb://localhost:27017/titanic');

############
#  Routes  #
############

app = express()

app.use(bodyParser.urlencoded({ extended: false }));
app.use(coffeeMiddleware({
	src: __dirname + '/assets'
	compress: true
}))
app.use(sassMiddleware({
	src: __dirname + '/assets/'
	dest: __dirname + '/public'
	outputStyle: 'compressed'
}))
app.use(cookieParser('titanic'))
app.use(session({
	secret: 'save the titanic!'
	resave: false
	saveUninitialized: true
}))
app.use(flash())

routes = {
	'': rfr('./controllers/core')
	'aliases': rfr('./controllers/aliases')
	'api': rfr('./controllers/api')
	'bash-shortcuts': rfr('./controllers/bash-shortcuts')
	'bash-functions': rfr('./controllers/bash-functions')
	'dashboard': rfr('./controllers/dashboard')
	'devices': rfr('./controllers/devices')
};

for stem, file of routes
	app.use('/' + stem, file)

# stop favicon requests
app.use('/favicon.ico', (req, res) -> res.end())

###########
#  Views  #
###########

app.set('views', path.join(__dirname, 'views'))
app.set('view engine', 'pug')
app.use(express.static(path.join(__dirname, 'public')))

####################
#  Error handlers  #
####################

app.use((req, res, next) ->
	err = new Error('Not Found')
	err.status = 404
	next(err)
)

app.use((error, req, res, next) ->
	res.status(error.status || 500)
	res.render('core/error', {
		_: {
			title: error.status + ': ' + error.message
		}
		message: error.message
		status: error.status || 500
		error: if app.get('env') == 'development' then error
	})
)

############
#  Start!  #
############

app.listen(c.PORT)
console.log("#{pJson.name} is listening on port #{c.PORT}")
