class AddStateToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :aasm_state, :string
  end
end
