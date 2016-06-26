class AddSlugToSkills < ActiveRecord::Migration
  def change
    add_column :skills, :slug, :string
    Skill.all.each do |skill|
      skill.update_attributes(slug: skill.title.parameterize)
    end
    change_column_null :skills, :slug, false

    add_index :skills, :slug, unique: true
  end
end
