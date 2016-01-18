class ChangeDefaultForOrganizationMembershipsToPending < ActiveRecord::Migration
  def up
    change_column_default :organization_memberships, :role, "pending"
  end

  def down
    change_column_default :organization_memberships, :role, "regular"
  end
end
