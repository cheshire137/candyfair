update_people_list = (response) ->
  list = $('.people-list')
  li = document.createElement('li')
  pref_list = document.createElement('ul')
  pref_list.className = 'person-preferences'
  pref_li = document.createElement('li')
  pref_li.className = 'preference- preference-0'
  person_link = document.createElement('a')
  person_link.href = response.preferences_url
  person_link.appendChild document.createTextNode(response.name)
  pref_li.appendChild person_link
  pref_list.appendChild pref_li
  li.appendChild pref_list
  list[0].appendChild li

$('form.add-person').on 'submit', (e) ->
  e.preventDefault()
  name_field = $('#new-person-name')
  options =
    method: 'POST'
    url: '/people.json'
    data:
      name: $.trim(name_field.val())
  on_success = (response) ->
    update_people_list response
    $('#person-error').text('').hide()
    name_field.val('').focus()
  on_error = (xhr, status, error) ->
    console.error 'failed to add new person', error
    $('#person-error').text('Could not add person').show()
  $.ajax(options).done(on_success).fail(on_error)
