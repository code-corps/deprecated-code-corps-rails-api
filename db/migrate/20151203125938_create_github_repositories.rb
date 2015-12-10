class CreateGithubRepositories < ActiveRecord::Migration
  def change
    create_table :github_repositories do |t|
      t.string :repository_name, null: false
      t.string :owner_name, null: false

      t.belongs_to :project, null: false

      t.timestamps null: false
    end
  end
end
