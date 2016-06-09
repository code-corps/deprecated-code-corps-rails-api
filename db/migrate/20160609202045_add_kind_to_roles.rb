class AddKindToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :kind, :string, null: false
  end
end
