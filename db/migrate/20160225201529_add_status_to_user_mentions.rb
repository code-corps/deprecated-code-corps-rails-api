class AddStatusToUserMentions < ActiveRecord::Migration
  def change
    add_column(:comment_user_mentions, :status, :string, null: false, default: "preview")
    add_column(:post_user_mentions, :status, :string, null: false, default: "preview")
  end
end
