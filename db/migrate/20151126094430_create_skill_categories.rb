class CreateSkillCategories < ActiveRecord::Migration
  def change
    create_table :skill_categories do |t|
      t.string :title, null: false

      t.timestamps null: false
    end
  end
end
