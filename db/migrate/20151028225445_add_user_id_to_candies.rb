class AddUserIdToCandies < ActiveRecord::Migration
  def up
    add_column :candies, :user_id, :integer
    user = User.first
    execute "UPDATE candies SET user_id = #{user.id}"
    add_index :candies, [:user_id, :name], unique: true
    change_column_null :candies, :user_id, false
  end

  def down
    remove_column :candies, :user_id
  end
end
