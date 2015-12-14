class AddStateToComments < ActiveRecord::Migration
  def change
    add_column :comments, :aasm_state, :string
  end
end
