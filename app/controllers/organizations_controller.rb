class OrganizationsController < ApplicationController

  def show
    organization = Organization.friendly.find(friendly_id)

    authorize Organization
    render json: organization
  end

  private

    def friendly_id
      params[:id] || params[:slug]
    end
end
