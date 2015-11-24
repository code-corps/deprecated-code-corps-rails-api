class AddTwitterWebsiteBiographyToUser < ActiveRecord::Migration
  def change
    add_column(:users, :website, :string)
    add_column(:users, :twitter, :string)
    add_column(:users, :biography, :string)
  end
end
