require "full-name-splitter"

class SplitNames < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :text
    add_column :users, :last_name, :text

    reversible do |dir|
      User.reset_column_information
      User.all.each do |u|
        dir.up   { u.first_name, u.last_name = FullNameSplitter.split(u.name) }
        dir.down { u.name = "#{u.first_name} #{u.last_name}" }
        u.save
      end
    end

    revert { add_column :users, :name, :text }
  end
end
