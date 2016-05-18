# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string           not null
#  ability    :string           not null
#

class RolesController < ApplicationController
  def index
    authorize Role
    render json: Role.all.includes(:skills)
  end
end
