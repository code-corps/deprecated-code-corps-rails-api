class AddSlugToUsersAndOrganizations < ActiveRecord::Migration
  def change
    add_column :users, :slug, :string
    User.all.each do |user|
      user.update_attributes(slug: user.username.downcase)
    end
    change_column_null :users, :slug, false


    add_column :organizations, :slug, :string
    Organization.all.each do |organization|
      organization.update_attributes(slug: organization.name.downcase)
    end
    change_column_null :organizations, :slug, false
  end
end
