class CreatePreviews < ActiveRecord::Migration
  def change
    create_table :previews do |t|
      t.text :body, null: false
      t.text :markdown, null: false

      t.belongs_to :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
