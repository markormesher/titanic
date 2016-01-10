$(document).ready(() ->

	# switch checkboxes
	$('.switch-checkbox').each((i, e) ->
		# get views
		e = $(e)
		input = e.find('input')
		icon = e.find('i').eq(0)

		# swap input for icon
		input.hide()
		icon.show()

		# set value
		changeFunc = () ->
			if (input.is(':checked'))
				icon.addClass('fa-toggle-on text-success').removeClass('fa-toggle-off text-muted')
			else
				icon.addClass('fa-toggle-off text-muted').removeClass('fa-toggle-on text-success')
		changeFunc()

		# set click listener
		e.click(() -> changeFunc())
	)

)