class AddIconDataToProjects < ActiveRecord::Migration
  def change
    add_column(:projects, :base_64_icon_data, :text)
  end
end
