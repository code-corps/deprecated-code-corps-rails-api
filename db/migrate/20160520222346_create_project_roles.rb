class CreateProjectRoles < ActiveRecord::Migration
  def change
    create_table :project_roles do |t|
      t.belongs_to :project
      t.belongs_to :role

      t.timestamps null: false
    end

    add_index :project_roles, [:project_id, :role_id], unique: true
    add_foreign_key :project_roles, :projects, on_delete: :cascade
    add_foreign_key :project_roles, :roles, on_delete: :cascade
  end
end
