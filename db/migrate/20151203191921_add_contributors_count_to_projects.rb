class AddContributorsCountToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :contributors_count, :integer
  end
end
