# == Schema Information
#
# Table name: organization_memberships
#
#  id              :integer          not null, primary key
#  role            :string           default("pending"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  member_id       :integer
#  organization_id :integer
#

class OrganizationMembershipsController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create, :update, :destroy]

  # /organizations/:id/memberships
  def index
    authorize organization_memberships
    render json: organization_memberships,
           meta: meta_for(organization_membership_count),
           each_serializer: OrganizationMembershipSerializer
  end

  def show
    organization_membership = OrganizationMembership.find(params[:id])

    authorize organization_membership

    render json: organization_membership
  end

  def create
    organization_membership = OrganizationMembership.new(create_params)

    authorize organization_membership

    if organization_membership.save
      render json: organization_membership
    else
      render_validation_errors organization_membership.errors
    end
  end

  def update
    organization_membership = OrganizationMembership.find(params[:id])
    organization_membership.assign_attributes(update_params)

    authorize organization_membership

    if organization_membership.save
      render json: organization_membership
    else
      render_validation_errors organization_membership.errors
    end
  end

  def destroy
    organization_membership = OrganizationMembership.find(params[:id])
    authorize organization_membership
    organization_membership.destroy!
    render json: :nothing, status: :no_content
  end

  private

    # for index

    def filter_params
      filter_params = {}
      filter_params[:organization] = organization
      filter_params[:role] = params[:role] if params[:role]
      filter_params
    end

    def organization_memberships
      OrganizationMembership.
        includes(:member).
        includes(:organization).
        where(filter_params).
        page(page_number).
        per(page_size)
    end

    def organization_membership_count
      OrganizationMembership.where(filter_params).count
    end

    def organization
      Organization.find(params[:organization_id])
    end

    # for create and update

    def update_params
      parse_params(params, only: [:role])
    end

    def create_params
      parse_params(params, only: [:role, :organization, :member])
    end
end
