$('a.set-preference').click (e) ->
  e.preventDefault()
  link = $(e.target)
  unless link.is('a.set-preference')
    link = link.closest('a.set-preference')
  candy_id = link.data('candy-id')
  person_id = link.data('person-id')
  type = link.data('preference-type')
  preference_id = link.data('preference-id')
  url = "/people/#{person_id}/preferences"
  if type == ''
    if preference_id
      url += "/#{preference_id}"
      method = 'DELETE'
    else
      return
  else
    method = 'POST'
  link.closest('.preference').find('li.active').removeClass 'active'
  url += '.json'
  options =
    method: method
    url: url
    data:
      type: type
      candy_id: candy_id
  on_success = (response) ->
    link.closest('li').addClass('active')
    preference_id = if response then response.id else ''
    link.closest('.preference').find('a.set-preference').
         attr('data-preference-id', preference_id)
    $('#preference-error').text('').hide()
  on_error = (xhr, status, error) ->
    console.error 'failed to save preference', error
    $('#preference-error').text('Could not save preference').show()
  $.ajax(options).done(on_success).fail(on_error)
