class AddWikipediaTitleToCandies < ActiveRecord::Migration
  def change
    add_column :candies, :wikipedia_title, :string
  end
end
