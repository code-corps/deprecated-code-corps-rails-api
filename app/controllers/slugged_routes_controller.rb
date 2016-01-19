# == Schema Information
#
# Table name: slugged_routes
#
#  id         :integer          not null, primary key
#  slug       :string           not null
#  owner_id   :integer
#  owner_type :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SluggedRoutesController < ApplicationController
  def show
    slugged_route = SluggedRoute.find_by_slug!(slug)

    authorize slugged_route

    render json: slugged_route, include: ["owner"]
  end

  def slug
    params[:id]
  end
end
