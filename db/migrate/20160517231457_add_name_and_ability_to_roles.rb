class AddNameAndAbilityToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :name, :string, null: false
    add_column :roles, :ability, :string, null: false
    remove_column :roles, :title
  end
end
