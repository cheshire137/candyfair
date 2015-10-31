json.imageUrls @image_urls
if @wiki_page
  json.title @wiki_page.title
  first_sentence = (@wiki_page.text || '').split(/\.\s+/).first
  json.text first_sentence ? first_sentence + '.' : ''
  json.wikipediaUrl @wiki_page.fullurl
end
if @image_urls.present?
  json.logoUrl @image_urls.detect {|u| u.downcase.include?('logo') }
end
