class AddMappingToSkillsAndRoles < ActiveRecord::Migration
  def change
    add_column :skills, :original_row, :integer
    add_column :role_skills, :cat, :integer
  end
end
