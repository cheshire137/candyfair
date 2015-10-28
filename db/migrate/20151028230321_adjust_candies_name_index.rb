class AdjustCandiesNameIndex < ActiveRecord::Migration
  def up
    remove_index :candies, :name
  end

  def down
    add_index "candies", ["name"], name: "index_candies_on_name", unique: true,
                                   using: :btree
  end
end
