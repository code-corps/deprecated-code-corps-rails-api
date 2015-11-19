class CreateProjectRelatedTables < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name, null: false

      t.timestamps null: false

      t.belongs_to :organization
    end

    create_table :organizations do |t|
      t.string :name, null: false

      t.timestamps null: false
    end

    create_table :projects do |t|
      t.string :name, null: false

      t.references :owner, polymorphic: true, index: true

      t.timestamps null: false
    end

    create_table :team_memberships do |t|
      t.timestamps null: false

      t.integer :member_id
      t.belongs_to :team

    end

    add_index :team_memberships, [:member_id, :team_id], unique: true

    create_table :organization_memberships do |t|
      t.string :role, default: "regular", null: false

      t.timestamps null: false

      t.integer :member_id
      t.belongs_to :organization
    end

    add_index :organization_memberships, [:member_id, :organization_id], unique: true
  end
end
