class AddSkipWikipediaToCandies < ActiveRecord::Migration
  def change
    add_column :candies, :skip_wikipedia, :boolean, default: false, null: false
  end
end
