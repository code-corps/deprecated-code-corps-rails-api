class DropTeamMembership < ActiveRecord::Migration
  def change
    drop_table :team_memberships
  end
end
