$(document).ready(() ->
	initDeleteButtonListener()
)

initDeleteButtonListener = () ->
	$('#delete-button').click((e) ->
		e.preventDefault()
		alert('Test')
	)