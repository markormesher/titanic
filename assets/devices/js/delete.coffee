$(document).ready(() ->
	initDeleteButtonListener()
)

initDeleteButtonListener = () ->
	$('.delete-button').click((e) ->
		e.preventDefault()
		t = $(this)
		bootbox.confirm(
			'Do you really want to delete <strong>' + t.data('name') + '</strong>?',
			(result) ->
				if (!result) then return
				window.location.href = '/devices/delete/' + t.data('id')
		)
	)
