$(document).ready(() ->

# switch checkboxes
	$('.switch-checkbox').each((i, e) ->
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
		input.change(() -> changeFunc())
	)

	# select all checkboxes
	$('.select-all-checkboxes').each((i, e) ->
		e = $(e)
		targets = $(e.data('target'))

		# default state
		allChecked = false
		checkState = () ->
			allChecked = targets.filter(':checked').length == targets.length
			e.html(if allChecked then 'Deselect All' else 'Select All')
		checkState()

		# update state when targets change
		targets.change(() -> checkState())

		# change them all on click
		e.click((ev) ->
			ev.preventDefault()
			newState = !allChecked
			targets.each((i, e) -> $(e).prop('checked', newState).change())
		)
	)
)
