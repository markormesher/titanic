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
	FunctionManager.get({}, (err, functions) ->
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
	res.render('bash-functions/edit', {
		_: {
			title: 'Create Function'
			activePage: 'bash-functions'
		}
	})
)

router.get('/edit/:functionId', (req, res) ->
	functionId = req.params.functionId

	FunctionManager.get({ id: functionId }, (err, funcs) ->
		if err or funcs == []
			req.flash('error', 'Sorry, that function couldn\'t be loaded!')
			res.writeHead(302, { Location: '/bash-functions' })
			res.end()
			return

		func = funcs[0]
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
	functionId = req.params.functionId
	func = req.body

	# normalise booleans
	func.available_internal = func.available_internal == '1'
	func.available_external = func.available_external == '1'

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

		res.writeHead(302, { Location: '/bash-functions' })
		res.end()
	)
)

router.get('/delete/:functionId', (req, res) ->
	functionId = req.params.functionId

	FunctionManager.delete(functionId, (err) ->
		if err
			log.error('Failed to delete function ' + functionId)
			req.flash('error', 'Sorry, something went wrong!')
		else
			log.event('Deleted function ' + functionId)
			req.flash('info', 'Function deleted.')

		res.writeHead(302, { Location: '/bash-functions' })
		res.end()
	)
)

module.exports = router;
