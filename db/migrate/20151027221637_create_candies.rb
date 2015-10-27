class CreateCandies < ActiveRecord::Migration
  def change
    create_table :candies do |t|
      t.string :name, null: false
      t.timestamps null: false
    end
    add_index :candies, :name, unique: true
  end
end
