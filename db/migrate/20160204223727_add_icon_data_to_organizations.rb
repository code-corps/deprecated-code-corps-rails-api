class AddIconDataToOrganizations < ActiveRecord::Migration
  def change
    add_column(:organizations, :base64_icon_data, :text)
  end
end
