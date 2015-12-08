class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :notifiable, polymorphic: true, null: false
      t.references :user, null: false
      t.string :aasm_state
      
      t.timestamps null: false
    end

    add_index :notifications, :user_id
    add_index :notifications, [:user_id, :notifiable_id, :notifiable_type], name: 'index_notifications_on_user_id_and_notifiable', unique: true
  end
end
