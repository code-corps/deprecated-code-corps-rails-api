class DropContributor < ActiveRecord::Migration
  def change
    drop_table :contributors
  end
end
