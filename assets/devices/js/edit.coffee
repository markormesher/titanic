$(document).ready(() ->
	if (device != null) then initDeleteButtonListener()
)

initDeleteButtonListener = () ->
	$('#delete-button').click((e) ->
		e.preventDefault()
		bootbox.confirm(
			'Do you really want to delete <strong>' + device.hostname + '</strong>?',
			(result) ->
				if (!result) then return
				window.location.href = '/devices/delete/' + device._id
		)
	)