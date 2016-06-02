class AddStateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :aasm_state, :string, default: "signed_up"
  end
end
