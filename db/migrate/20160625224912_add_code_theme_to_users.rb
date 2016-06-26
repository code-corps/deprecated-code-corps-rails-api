class AddCodeThemeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :theme, :string, default: "light", null: false
  end
end
