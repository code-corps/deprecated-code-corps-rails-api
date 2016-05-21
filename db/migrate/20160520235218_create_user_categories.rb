class CreateUserCategories < ActiveRecord::Migration
  def change
    create_table :user_categories do |t|
      t.belongs_to :user
      t.belongs_to :category

      t.timestamps null: false
    end

    add_index :user_categories, [:user_id, :category_id], unique: true
    add_foreign_key :user_categories, :users, on_delete: :cascade
    add_foreign_key :user_categories, :categories, on_delete: :cascade
  end
end
