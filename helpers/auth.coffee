funcs = {
	checkOnly: (req, res, next)->
		res.locals.user = req.user || null
		next()

	checkAndRefuse: (req, res, next)->
		if (req.user)
			funcs.checkOnly(req, res, next)
		else
			req.flash('error', 'You need to log in first.')
			res.redirect('/auth/login')
}

module.exports = funcs
