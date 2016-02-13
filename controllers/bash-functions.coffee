##################
#  Dependencies  #
##################

express = require('express')
rfr = require('rfr')
async = require('async')
log = rfr('./helpers/log')

# managers
FunctionManager = rfr('./managers/bash-functions')

##############
#  Mappings  #
##############

router = express.Router();

router.get('/', (req, res) ->
	# get all functions
	FunctionManager.get((err, functions) ->
		# render output
		res.render('bash-functions/index', {
			_: {
				title: 'Bash Functions'
				activePage: 'bash-functions'
			}
			functions: functions
		})
	)
)

router.get('/create', (req, res) ->
	# render output
	res.render('bash-functions/edit', {
		_: {
			title: 'Create Function'
			activePage: 'bash-functions'
		}
	})
)

router.get('/edit/:functionId', (req, res) ->
	# get parameters
	functionId = req.params.functionId

	# find function
	FunctionManager.get(functionId, (err, func) ->
	# check for function
		if err or func == null
			req.flash('error', 'Sorry, that function couldn\'t be loaded!')
			res.writeHead(302, {Location: '/bash-functions'})
			res.end()
			return

		# render output
		res.render('bash-functions/edit', {
			_: {
				title: 'Edit Function: ' + func.name
				activePage: 'bash-functions'
			}
			func: func
		})
	)
)

router.post('/edit/:functionId', (req, res) ->
	# get parameters
	functionId = req.params.functionId
	func = req.body

	# normalise booleans
	func.available_internal = func.available_internal == '1'
	func.available_external = func.available_external == '1'

	# save in DB
	FunctionManager.createOrUpdate(functionId, func, (err, functionId, createdNew) ->
		# forward to list
		if err
			log.error('Failed to update function ' + functionId)
			req.flash('error', 'Sorry, something went wrong!')
		else
			if createdNew
				log.event('Created function ' + functionId)
				req.flash('success', 'The function <strong>' + func.name + '</strong> was created!')
			else
				log.event('Edited function ' + functionId)
				req.flash('success', 'Your changes were saved!')

		res.writeHead(302, {Location: '/bash-functions'})
		res.end()
	)
)

router.get('/delete/:functionId', (req, res) ->
	# get parameters
	functionId = req.params.functionId

	# delete function
	FunctionManager.delete(functionId, (err) ->
		if err
			log.error('Failed to delete function ' + functionId)
			req.flash('error', 'Sorry, something went wrong!')
		else
			log.event('Deleted function ' + functionId)
			req.flash('info', 'Function deleted.')

		res.writeHead(302, {Location: '/bash-functions'})
		res.end()
	)
)

module.exports = router;