class CreatePreviewUserMentions < ActiveRecord::Migration
  def change
    create_table :preview_user_mentions do |t|
      t.belongs_to :user, index: true, foreign_key: true, null: false
      t.belongs_to :preview, index: true, foreign_key: true, null: false

      t.string :username, null: false
      t.integer :start_index, null: false
      t.integer :end_index, null: false

      t.timestamps null: false
    end
  end
end
