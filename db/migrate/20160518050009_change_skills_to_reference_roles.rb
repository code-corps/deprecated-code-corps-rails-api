class ChangeSkillsToReferenceRoles < ActiveRecord::Migration
  def change
    rename_column :skills, :skill_category_id, :role_id
  end
end
