class AddSlugToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :slug, :string
    Organization.all.each do |organization|
      organization.update_attributes(slug: organization.name.parameterize)
    end
    change_column_null :organizations, :slug, false

    add_index :organizations, :slug, :unique => true
  end
end
