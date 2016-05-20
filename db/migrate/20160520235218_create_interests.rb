class CreateInterests < ActiveRecord::Migration
  def change
    create_table :interests do |t|
      t.belongs_to :user
      t.belongs_to :category

      t.timestamps null: false
    end

    add_index :interests, [:user_id, :category_id], unique: true
    add_foreign_key :interests, :users, on_delete: :cascade
    add_foreign_key :interests, :categories, on_delete: :cascade
  end
end
