class RenameUseridPosts < ActiveRecord::Migration[6.0]
  def change
    rename_column :posts, :userId, :user_id
    change_column_null :posts, :user_id, false
  end
end
