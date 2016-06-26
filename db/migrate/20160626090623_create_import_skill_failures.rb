class CreateImportSkillFailures < ActiveRecord::Migration
  def change
    create_table :import_skill_failures do |t|
      t.belongs_to :import, null: false
      t.belongs_to :skill, null: true

      t.json :data, null: false
      t.text :issues, null: false, array: true

      t.timestamps null: false
    end
  end
end
