class AddNumberToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :number, :integer, null: false

    add_index :posts, [:number, :project_id], unique: true
  end
end
