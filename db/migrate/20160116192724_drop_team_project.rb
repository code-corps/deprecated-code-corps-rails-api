class DropTeamProject < ActiveRecord::Migration
  def change
    drop_table :team_projects
  end
end
