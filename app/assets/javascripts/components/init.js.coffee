$.ajaxSetup(
    Accept: 'application/json',
    dataType: 'json',
    type: 'POST',
    beforeSend: (xhr) ->
      token = $('meta[name="csrf-token"]').attr('content')
      if (token)
        xhr.setRequestHeader('X-CSRF-Token', token)


      atoken = $('meta[name="auth_token"]').attr('content')
      if (atoken)
        xhr.setRequestHeader('Authorization', 'Token token=' + atoken)
)

$(document).ajaxError ( event, jqxhr, settings, exception ) ->
  console.log "Error: ", exception
  alert("Error: " + exception.message)


