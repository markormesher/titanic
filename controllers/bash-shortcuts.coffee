##################
#  Dependencies  #
##################

express = require('express')
rfr = require('rfr')
async = require('async')
mongoose = require('mongoose')
log = rfr('./helpers/log')

# models
BashShortcut = rfr('./models/bash-shortcut')

##############
#  Mappings  #
##############

router = express.Router();

router.get('/', (req, res) ->
	# get all shortcuts
	BashShortcut.find({}).sort({short_command: 'asc'}).exec((err, shortcuts) ->
		# render output
		res.render('bash-shortcuts/index', {
			_: {
				title: 'Bash Shortcuts'
				activePage: 'bash-shortcuts'
			}
			shortcuts: shortcuts
		})
	)
)

router.get('/create', (req, res) ->
	# render output
	res.render('bash-shortcuts/edit', {
		_: {
			title: 'Create Shortcut'
			activePage: 'bash-shortcuts'
		}
		shortcut: null
	})
)

router.get('/edit/:shortcutId', (req, res) ->
	# get parameters
	shortcutId = req.params.shortcutId

	# find shortcut
	BashShortcut.find({_id: shortcutId}).exec((err, shortcut) ->
	# check for shortcut
		if (false && err)
			req.flash('error', 'Sorry, that shortcut couldn\'t be loaded!')
			res.writeHead(302, {Location: '/bash-shortcuts'})
			res.end()
			return
		else
			shortcut = shortcut[0]

		# render output
		res.render('bash-shortcuts/edit', {
			_: {
				title: 'Edit Shortcut: ' + shortcut.short_command
				activePage: 'bash-shortcuts'
			}
			shortcut: shortcut
		})
	)
)

router.post('/edit/:shortcutId', (req, res) ->
	# get parameters
	shortcutId = req.params.shortcutId
	if (shortcutId == null || shortcutId == 0 || shortcutId == '0') then shortcutId = false
	shortcut = req.body

	# build create/edit query
	query = {
		_id: (if shortcutId then shortcutId else mongoose.Types.ObjectId())
	}

	# save in DB
	BashShortcut.update(query, shortcut, {upsert: true}, (err) ->
		if (err) then throw err

		# log
		log.event((if shortcutId then 'Edited' else 'Created') + ' shortcut (' + query._id + ')')

		# forward to list
		if err
			req.flas('error', 'Sorry, something went wrong!')
		else
			if shortcutId
				req.flash('success', 'Your changes were saved!')
			else
				req.flash('success', 'The shortcut <strong>' + shortcut.short_command + '</strong> was created!')
		res.writeHead(302, {Location: '/bash-shortcuts'})
		res.end()
	)
)

router.get('/delete/:shortcutId', (req, res) ->
	# get parameters
	shortcutId = req.params.shortcutId

	# delete shortcut
	BashShortcut.remove({_id: shortcutId}, (err) ->
		# log
		log.event('Deleted Bash shortcut (' + shortcutId + ')')

		req.flash('info', 'Shortcut deleted.')
		res.writeHead(302, {Location: '/bash-shortcuts'})
		res.end()
	)
)

module.exports = router;