class CreateUserRelationships < ActiveRecord::Migration
  def change
    create_table :user_relationships do |t|

      t.belongs_to :follower, index: true
      t.belongs_to :following, index: true

      t.timestamps null: false
    end
  end
end
