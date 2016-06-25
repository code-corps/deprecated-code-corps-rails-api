class AddOrganizationToProjects < ActiveRecord::Migration
  def change
    add_reference :projects, :organization, null: false, index: true, foreign_key: true
  end
end
