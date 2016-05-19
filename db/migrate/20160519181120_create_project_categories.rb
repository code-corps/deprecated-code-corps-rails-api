class CreateProjectCategories < ActiveRecord::Migration
  def change
    create_table :project_categories do |t|
      t.belongs_to :project
      t.belongs_to :category

      t.timestamps null: false
    end
  end
end
