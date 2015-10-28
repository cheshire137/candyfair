json.id @person.to_param
json.extract! @person, :name, :user_id
json.preferences_url person_preferences_url(@person)
