class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :status, default: "open"
      t.string :type, default: "task"
      t.string :title, null: false
      t.text :body

      t.belongs_to :user
      t.belongs_to :project

      t.timestamps null: false
    end
  end
end
