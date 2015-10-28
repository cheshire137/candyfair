$('form.add-candy').on 'submit', (e) ->
  e.preventDefault()
  name_field = $('#new-candy-name')
  options =
    method: 'POST'
    url: '/candies.json'
    data:
      name: $.trim(name_field.val())
  on_success = (response) ->
    $('.candies-list').text(response.candies_list)
    $('#add-candy-error').text('').hide()
    name_field.val('').focus()
  on_error = (xhr, status, error) ->
    console.error 'failed to add new candy', error
    $('#add-candy-error').text('Could not add candy').show()
  $.ajax(options).done(on_success).fail(on_error)
