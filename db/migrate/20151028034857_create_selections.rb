class CreateSelections < ActiveRecord::Migration
  def change
    create_table :selections do |t|
      t.integer :candy_id, null: false
      t.integer :quantity, null: false, default: 1
      t.integer :user_id, null: false
      t.timestamps null: false
    end
    add_index :selections, [:candy_id, :user_id], unique: true
    add_index :selections, :user_id
  end
end
