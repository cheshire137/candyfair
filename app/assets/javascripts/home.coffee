reset_distribution_filters = ->
  $('.distribution-list li').show()

$('select.filter-distribution-candy').change (e) ->
  $('select.filter-distribution-person').val('')
  reset_distribution_filters()
  candy_id = $(e.target).val()
  return if candy_id == ''
  $('.distribution-list li').each ->
    li = $(this)
    li_candies = li.data('candy-ids') + ''
    li_candies = li_candies.split(',')
    if li_candies.indexOf(candy_id) < 0
      li.hide()
    else
      li.show()

$('select.filter-distribution-person').change (e) ->
  $('select.filter-distribution-candy').val('')
  reset_distribution_filters()
  select = $(e.target)
  person_id = select.val()
  return if person_id == ''
  $('.distribution-list li').each ->
    li = $(this)
    li_people = li.data('person-ids') + ''
    li_people = li_people.split(',')
    if li_people.indexOf(person_id) < 0
      li.hide()
    else
      li.show()
  message_el = $('#no-ratings-by-person-message')
  if $('.distribution-list li:visible').length < 1
    person_name = select.find('option:selected').text()
    message_el.find('.person').text(person_name)
    message_el.show()
  else
    message_el.hide()
