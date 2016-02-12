class AddIconColumnsToOrganizations < ActiveRecord::Migration
  def up
    add_attachment :organizations, :icon
  end

  def down
    remove_attachment :organizations, :icon
  end
end
