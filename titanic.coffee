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
passport = require('passport')
rfr = require('rfr')
c = rfr('./helpers/constants')
auth = rfr('./helpers/auth')
pJson = rfr('./package.json')
mysql = rfr('./helpers/mysql')

##########################
#  Database connections  #
##########################

mysql.getConnection((conn) -> console.log("MySQL connected with ID #{conn.threadId}"))

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

# auth config
rfr('./helpers/passport-config')(passport)
app.use(passport.initialize())
app.use(passport.session())
app.use(auth.checkOnly)

routes = {
	'': rfr('./controllers/core')
	'aliases': rfr('./controllers/aliases')
	'api': rfr('./controllers/api')
	'auth': rfr('./controllers/auth')
	'bash-shortcuts': rfr('./controllers/bash-shortcuts')
	'bash-functions': rfr('./controllers/bash-functions')
	'dashboard': rfr('./controllers/dashboard')
	'devices': rfr('./controllers/devices')
	'users': rfr('./controllers/users')
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

app.use((error, req, res) ->
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
