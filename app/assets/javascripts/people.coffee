update_people_list = (response) ->
  list = $('.people-list')
  new_people_message = $('#new-people-message')
  has_preferences = new_people_message.data('has-preferences') == 'true'
  $('#add-people-instructions').hide()
  if list.find('li').length == 0 && !has_preferences
    new_people_message.show()
  else
    new_people_message.hide()
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
  $('#people-divider').show()

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

reset_filters = ->
  $('li.preference .preference-data, li.preference:empty').show()
  $('.people-list .candy, .people-list .candy .candy-separator').show()

$('select.filter-type').change (e) ->
  $('select.filter-candy').val('')
  reset_filters()
  type = $(e.target).val()
  if type == ''
    reset_filters()
  else
    type = type.toLowerCase() + 's'
    $('li.preference .preference-data, li.preference:empty').hide()
    $('li.preference-' + type + ' .preference-data').show()

$('select.filter-candy').change (e) ->
  $('select.filter-type').val('')
  reset_filters()
  candy_id = $(e.target).val()
  if candy_id == ''
    reset_filters()
  else
    $('.people-list .candy').hide()
    $('.people-list .candy-' + candy_id).show().find('.candy-separator').hide()
    $('li.preference .preference-data').each ->
      pref = $(this)
      pref_candies = pref.data('candy-ids') + ''
      pref_candies = pref_candies.split(',')
      if pref_candies.indexOf(candy_id) < 0
        pref.hide()
      else
        pref.show()
