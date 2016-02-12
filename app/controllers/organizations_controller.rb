# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  slug       :string           not null
#

class OrganizationsController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create]

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

  private
    def create_params
      record_attributes.permit(:name, :slug, :base64_icon_data)
    end
end
