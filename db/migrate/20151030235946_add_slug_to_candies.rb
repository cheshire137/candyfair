class AddSlugToCandies < ActiveRecord::Migration
  def change
    add_column :candies, :slug, :string
  end
end
