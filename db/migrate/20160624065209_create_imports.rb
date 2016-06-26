class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.attachment :file
      t.integer :status, default: 0

      t.timestamps null: false
    end
  end
end
