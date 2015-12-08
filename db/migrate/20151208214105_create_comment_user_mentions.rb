class CreateCommentUserMentions < ActiveRecord::Migration
  def change
    create_table :comment_user_mentions do |t|
      t.belongs_to :user, null: false
      t.belongs_to :comment, null: false

      t.string :username, null: false
      t.integer :start_index, null: false
      t.integer :end_index, null: false

      t.timestamps null: false
    end
  end
end
