update_candies_list = (response) ->
  last_column = $('.candies-lists-container div.col:last-child')
  penultimate_column = last_column.prev('div.col')
  last_column_size = last_column.find('ul.candies-list li').length
  penultimate_column_size = penultimate_column.find('ul.candies-list li').length
  same_length = last_column_size == penultimate_column_size
  li = document.createElement('li')
  link = document.createElement('a')
  link.href = response.url
  link.className = 'highlight'
  link.appendChild document.createTextNode(response.name)
  li.appendChild link
  if same_length
    list = document.createElement('ul')
    list.className = 'candies-list'
    new_column = document.createElement('div')
    new_column.className = last_column[0].className
    new_column.appendChild list
    $('.candies-lists-container')[0].appendChild new_column
  else
    list = last_column.find('ul.candies-list')[0]
  removeLinkHighlight = ->
    link.className = ''
  list.appendChild li
  setTimeout removeLinkHighlight, 2000

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

$('form.delete-candy').submit (e) ->
  message = 'Are you sure you want to delete this candy?'
  unless confirm(message)
    e.preventDefault()

load_wikipedia_data = ->
  container = $('.wikipedia')
  url = container.data('url')
  $.getJSON url, (response) ->
    container.empty()
    if response.text.length > 0
      blockquote = document.createElement('blockquote')
      blockquote.className = 'wikipedia-description'
      blockquote.setAttribute 'cite', response.wikipediaUrl
      blockquote.appendChild document.createTextNode(response.text)
      link = document.createElement('a')
      link.className = 'wikipedia-link'
      link.href = response.wikipediaUrl
      link_text = 'Wikipedia page "' + response.title + '"'
      link.appendChild document.createTextNode(link_text)
      if response.imageUrls.length > 0
        imageLink = document.createElement('a')
        imageLink.className = 'wikipedia-image-link'
        imageLink.href = response.wikipediaUrl
        image = document.createElement('img')
        image.src = response.logoUrl || response.imageUrls[0]
        image.setAttribute 'alt', 'Image of ' + response.title
        image.className = 'wikipedia-image'
        imageLink.appendChild image
        $('.wikipedia-image-wrapper')[0].appendChild imageLink
      container[0].appendChild blockquote
      container[0].appendChild link

$ ->
  if $('.wikipedia').length > 0
    load_wikipedia_data()
