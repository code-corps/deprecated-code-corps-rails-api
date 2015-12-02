class OrganizationsController < ApplicationController

  def show
    if find_by_id?
      organization = Organization.find(params[:id])
    elsif find_by_slug?
      organization = Organization.find_by_slug(params[:slug])
    end

    authorize Organization
    render json: organization
  end

  private

    def find_by_id?
      params[:id].present?
    end

    def find_by_slug?
      params[:slug].present?
    end
end
