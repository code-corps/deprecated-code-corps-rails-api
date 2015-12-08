class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :slug, null: false
      t.references :model, polymorphic: true

      t.timestamps null: false
    end

    add_index :members, :slug, unique: true
    add_index :members, [:model_id, :model_type], unique: true
  end
end
