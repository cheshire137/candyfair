json.extract! @candy, :name
json.api_url candy_url(@candy, format: :json)
json.url candy_url(@candy, format: :html)
json.id @candy.to_param
json.wiki_url wikipedia_candy_url(@candy)
