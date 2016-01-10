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

module.exports = router;