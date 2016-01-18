# == Schema Information
#
# Table name: github_repositories
#
#  id              :integer          not null, primary key
#  repository_name :string           not null
#  owner_name      :string           not null
#  project_id      :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require "code_corps/github_repository_url_parser"

class GithubRepositoriesController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create]

  def create
    github_repository = GithubRepository.new(create_params)
    authorize github_repository

    if github_repository.valid?
      github_repository.save!
      render json: github_repository
    else
      render_validation_errors github_repository.errors
    end
  end

  private
    def create_params
      parsed_attributes.merge(relationships)
    end

    def url
      record_attributes.require(:url)
    end

    def parsed_attributes
      parser = CodeCorps::GithubRepositoryUrlParser.new(url)
      return {
        repository_name: parser.repository_name,
        owner_name: parser.owner_name
      }
    end

    def relationships
      { project_id: project_id }
    end

    def project_id
      record_relationships.fetch(:project, {}).fetch(:data, {}).require(:id)
    end
end
