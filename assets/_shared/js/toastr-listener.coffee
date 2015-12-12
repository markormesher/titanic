$(document).ready(() ->
	for m in toastrMessages
		if (typeof(m) is 'string') then m = ['success', m]

		switch m[0]
			when 'error' then toastr.error(m[1])
			when 'info' then toastr.info(m[1])
			when 'success' then toastr.success(m[1])
			when 'warning' then toastr.warning(m[1])
)