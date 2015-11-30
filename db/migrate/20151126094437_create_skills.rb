class CreateSkills < ActiveRecord::Migration
  def change
    create_table :skills do |t|
      t.string :title, null: false
      t.string :description

      t.belongs_to :skill_category

      t.timestamps null: false
    end
  end
end
