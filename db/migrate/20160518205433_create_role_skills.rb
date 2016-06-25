class CreateRoleSkills < ActiveRecord::Migration
  def change
    create_table :role_skills do |t|
      t.belongs_to :role
      t.belongs_to :skill

      t.timestamps null: false
    end
  end
end
