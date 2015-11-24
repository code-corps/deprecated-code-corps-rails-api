class AddTwitterWebsiteBiographyToUser < ActiveRecord::Migration
  def change
    add_column(:users, :website, :text)
    add_column(:users, :twitter, :text)
    add_column(:users, :biography, :text)
  end
end
