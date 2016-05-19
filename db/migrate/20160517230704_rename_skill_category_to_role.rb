class RenameSkillCategoryToRole < ActiveRecord::Migration
  def change
    rename_table :skill_categories, :roles
  end
end
