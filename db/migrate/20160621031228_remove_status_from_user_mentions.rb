class RemoveStatusFromUserMentions < ActiveRecord::Migration
  def change
    remove_column :comment_user_mentions, :status, :string, null: false, default: "preview"
    remove_column :post_user_mentions, :status, :string, null: false, default: "preview"
  end
end
