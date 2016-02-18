# == Schema Information
#
# Table name: organizations
#
#  id                :integer          not null, primary key
#  name              :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  slug              :string           not null
#  icon_file_name    :string
#  icon_content_type :string
#  icon_file_size    :integer
#  icon_updated_at   :datetime
#  base64_icon_data  :text
#

class OrganizationsController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create, :update]

  def show
    organization = Organization.find(params[:id])

    authorize organization

    render json: organization
  end

  def create
    authorize Organization

    organization = Organization.new(create_params)

    if organization.valid?
      organization.save!
      AddOrganizationIconWorker.perform_async(organization.id)

      render json: organization
    else
      render_validation_errors organization.errors
    end
  end

  def update
    organization = Organization.find(params[:id])

    authorize organization

    organization.update(update_params)

    if organization.save
      AddOrganizationIconWorker.perform_async(organization.id)
      render json: organization
    else
      render_validation_errors(organization.errors)
    end
  end

  private
    def create_params
      record_attributes.permit(:name, :slug, :description, :base64_icon_data)
    end

    def update_params
      record_attributes.permit(:name, :description, :base64_icon_data)
    end

    def update_params
      # For now, slugs should not be updated until we've thought through repercussions more
      record_attributes.permit(:name, :base64_icon_data)
    end
end
