class AddIndexesAndForeignKeysToProjectCategories < ActiveRecord::Migration
  def change
    add_index :project_categories, [:project_id, :category_id], unique: true
    add_foreign_key :project_categories, :projects, on_delete: :cascade
    add_foreign_key :project_categories, :categories, on_delete: :cascade
  end
end
