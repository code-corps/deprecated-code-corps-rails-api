require "full-name-splitter"

class SplitFullNameIntoFirstAndLast < ActiveRecord::Migration
  def self.up
    User.transaction do
      users = User.all
      users.each do |user|
        name_array = FullNameSplitter.split(user.name)
        user.update(
          first_name: name_array[0],
          last_name: name_array[1]
        )
      end
    end
  end

  def self.down
  end
end
