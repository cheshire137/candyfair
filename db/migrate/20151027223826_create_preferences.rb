class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :preferences do |t|
      t.string :type
      t.integer :candy_id, null: false
      t.integer :person_id, null: false
      t.timestamps null: false
    end
    add_index :preferences, [:type, :candy_id, :person_id], unique: true
    add_index :preferences, :candy_id
    add_index :preferences, :person_id
  end
end
