$(document).ready(() ->
	initDeleteButtonListener()
)

initDeleteButtonListener = () ->
	$('.delete-button').click((e) ->
		e.preventDefault()
		bootbox.confirm(
			'Do you really want to delete <strong>' + $(this).data('name') + '</strong>?',
			(result) ->
				if (!result) then return
				window.location.href = '/devices/delete/' + $(this).data('id')
		)
	)