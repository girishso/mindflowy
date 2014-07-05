# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  proxied = window.alert
  window.alert = ->
    $("#myModal .modal-body").text(arguments[0])
    $("#myModal").modal('show')

    #proxied.apply this, arguments

  $("#sign_in_form").submit (e)->
    e.preventDefault()
    $.post("/login", $(this).serialize(),( (data) ->
        console.log data
    ),
       'json'
    )
