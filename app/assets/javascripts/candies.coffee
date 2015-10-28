linkify_candies = ->
  container = $('.candies-list')
  candy_names = container.text().split(',')
  candy_names = ($.trim(name) for name in candy_names)
  last_name = candy_names[candy_names.length - 1]
  last_name = last_name.replace(/^and /, '').replace(/\.$/, '')
  candy_names[candy_names.length - 1] = last_name
  links = []
  for name in candy_names
    link = document.createElement('a')
    link.href = '#'
    link.className = 'remove-candy'
    link.appendChild document.createTextNode(name)
    links.push link
  container.empty()
  i = 0
  container_el = container[0]
  for link in links
    container_el.appendChild link
    if i == links.length - 2 and links.length > 2
      container_el.appendChild document.createTextNode(' and ')
    else if i < links.length - 1
      container_el.appendChild document.createTextNode(', ')
    i++
  container_el.appendChild document.createTextNode('.')

update_candies_list = (response) ->
  $('.candies-list').text(response.candies_list)
  linkify_candies()

$('form.add-candy').on 'submit', (e) ->
  e.preventDefault()
  name_field = $('#new-candy-name')
  options =
    method: 'POST'
    url: '/candies.json'
    data:
      name: $.trim(name_field.val())
  on_success = (response) ->
    update_candies_list response
    $('#candy-error').text('').hide()
    name_field.val('').focus()
  on_error = (xhr, status, error) ->
    console.error 'failed to add new candy', error
    $('#candy-error').text('Could not add candy').show()
  $.ajax(options).done(on_success).fail(on_error)

$('body').on 'click', 'a.remove-candy', (e) ->
  e.preventDefault()
  link = $(e.target)
  name = link.text()
  unless confirm("Are you sure you want to delete #{name}?")
    link.blur()
    return
  options =
    method: 'DELETE'
    url: '/candies.json'
    data:
      name: name
  on_success = (response) ->
    update_candies_list response
    $('#candy-error').text('').hide()
  on_error = (xhr, status, error) ->
    console.error 'failed to delete candy ' + name, error
    $('#candy-error').text('Could not delete candy').show()
  $.ajax(options).done(on_success).fail(on_error)

$ ->
  if $('.candies-list').length > 0
    linkify_candies()
