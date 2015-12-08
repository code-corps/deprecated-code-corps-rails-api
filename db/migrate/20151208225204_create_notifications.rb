class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :notifiable, polymorphic: true

      t.timestamps null: false
    end

    add_index :notifications, [:notifiable_id, :notifiable_type], unique: true
  end
end
