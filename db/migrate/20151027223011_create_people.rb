class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :name, null: false
      t.integer :created_by_user_id, null: false
      t.timestamps null: false
    end
    add_index :people, [:name, :created_by_user_id], unique: true
  end
end
