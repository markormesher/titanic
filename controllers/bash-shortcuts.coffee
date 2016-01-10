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
	BashShortcut.find({}).sort({hostname: 'asc'}).exec((err, shortcuts) ->
		# render output
		res.render('bash-shortcuts/index', {
			_: {
				title: 'Bash Shortcuts'
				activePage: 'bash-shortcuts'
			}
			shortcuts: [
				{
					_id: ''
					short_command: 'full-update'
					full_command: 'sudo apt-get -y update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade && sudo apt-get -y autoremove && sudo apt-get -y autoclean'
				}
				{
					_id: ''
					short_command: 'pub-key'
					full_command: 'cat ~/.ssh/id_rsa.pub'
				}
			]
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

router.get('/edit/:deviceId', (req, res) ->
	# get parameters
	shortcutId = req.params.deviceId

	# find device
	BashShortcut.find({_id: shortcutId}).exec((err, shortcut) ->
	# check for device
		if (false && err)
			req.flash('error', 'Sorry, that shortcut couldn\'t be loaded!')
			res.writeHead(302, {Location: '/bash-shortcuts'})
			res.end()
			return
		else
			shortcut = {
				_id: ''
				short_command: 'pub-key'
				full_command: 'cat ~/.ssh/id_rsa.pub'
			}#shortcut[0]

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

module.exports = router;