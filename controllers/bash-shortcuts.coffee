##################
#  Dependencies  #
##################

express = require('express')
rfr = require('rfr')
async = require('async')
log = rfr('./helpers/log')

# managers
ShortcutManager = rfr('./managers/bash-shortcuts')

##############
#  Mappings  #
##############

router = express.Router();

router.get('/', (req, res) ->
	ShortcutManager.get({}, (err, shortcuts) ->
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
	res.render('bash-shortcuts/edit', {
		_: {
			title: 'Create Shortcut'
			activePage: 'bash-shortcuts'
		}
	})
)

router.get('/edit/:shortcutId', (req, res) ->
	shortcutId = req.params.shortcutId

	ShortcutManager.get({id: shortcutId}, (err, shortcuts) ->
		if err or shortcuts == []
			req.flash('error', 'Sorry, that shortcut couldn\'t be loaded!')
			res.writeHead(302, {Location: '/bash-shortcuts'})
			res.end()
			return

		# render output
		shortcut = shortcuts[0]
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
	shortcutId = req.params.shortcutId
	shortcut = req.body

	# normalise booleans
	shortcut.available_internal = shortcut.available_internal == '1'
	shortcut.available_external = shortcut.available_external == '1'

	ShortcutManager.createOrUpdate(shortcutId, shortcut, (err, shortcutId, createdNew) ->
		# forward to list
		if err
			log.error('Failed to update shortcut ' + shortcutId)
			req.flash('error', 'Sorry, something went wrong!')
		else
			if createdNew
				log.event('Created shortcut ' + shortcutId)
				req.flash('success', 'The shortcut <strong>' + shortcut.short_command + '</strong> was created!')
			else
				log.event('Edited shortcut ' + shortcutId)
				req.flash('success', 'Your changes were saved!')

		res.writeHead(302, {Location: '/bash-shortcuts'})
		res.end()
	)
)

router.get('/delete/:shortcutId', (req, res) ->
	shortcutId = req.params.shortcutId

	ShortcutManager.delete(shortcutId, (err) ->
		if err
			log.error('Failed to delete shortcut ' + shortcutId)
			req.flash('error', 'Sorry, something went wrong!')
		else
			log.event('Deleted shortcut ' + shortcutId)
			req.flash('info', 'Shortcut deleted.')

		res.writeHead(302, {Location: '/bash-shortcuts'})
		res.end()
	)
)

module.exports = router;
