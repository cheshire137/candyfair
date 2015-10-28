class RenamePeopleCreatedByUserIdToUserId < ActiveRecord::Migration
  def change
    rename_column :people, :created_by_user_id, :user_id
  end
end
