class CreateTeamProjects < ActiveRecord::Migration
  def change
    create_table :team_projects do |t|
      t.belongs_to :team, null: false
      t.belongs_to :project, null: false

      t.string :role, default: "regular", null: false

      t.timestamps null: false
    end

    add_index :team_projects, [:team_id, :project_id], unique: true
  end
end
