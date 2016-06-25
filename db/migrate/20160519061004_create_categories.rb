class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps null: false
    end

    add_index :categories, :slug, unique: true
  end
end
