class RemoveRoleIdFromSkills < ActiveRecord::Migration
  def change
    remove_column :skills, :role_id
  end
end
