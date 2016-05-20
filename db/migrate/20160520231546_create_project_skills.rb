class CreateProjectSkills < ActiveRecord::Migration
  def change
    create_table :project_skills do |t|
      t.belongs_to :project
      t.belongs_to :skill

      t.timestamps null: false
    end

    add_index :project_skills, [:project_id, :skill_id], unique: true
    add_foreign_key :project_skills, :projects, on_delete: :cascade
    add_foreign_key :project_skills, :skills, on_delete: :cascade
  end
end
