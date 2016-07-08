# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string           not null
#  ability    :string           not null
#  kind       :string           not null
#

class RolesController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:create]

  def index
    authorize Role
    render json: Role.all
  end

  def create
    role = Role.new(permitted_params)

    authorize role

    if role.save
      render json: role
    else
      render_validation_errors role.errors
    end
  end

  private

    def permitted_params
      parse_params(params, only: [:name, :ability, :kind])
    end
end
