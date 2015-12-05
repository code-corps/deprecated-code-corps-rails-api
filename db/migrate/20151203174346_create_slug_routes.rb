class CreateSlugRoutes < ActiveRecord::Migration
  def change
    create_table :slug_routes do |t|
      t.string :slug, null: false
      t.references :owner, polymorphic: true

      t.timestamps null: false
    end

    add_index :slug_routes, :slug, unique: true
    add_index :slug_routes, [:owner_id, :owner_type], unique: true
  end
end
