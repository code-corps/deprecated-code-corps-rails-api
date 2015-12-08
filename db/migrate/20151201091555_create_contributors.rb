class CreateContributors < ActiveRecord::Migration
  def change
    create_table :contributors do |t|
      t.belongs_to :user
      t.belongs_to :project

      t.string :status, null: false, default: "pending"

      t.timestamps null: false
    end
  end
end
