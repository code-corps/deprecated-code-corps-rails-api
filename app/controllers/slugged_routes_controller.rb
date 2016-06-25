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
    slugged_route = SluggedRoute.where("lower(slug) = ?", downcased_slug).first!

    authorize slugged_route

    render json: slugged_route
  end

  private

    def downcased_slug
      slug.downcase
    end

    def slug
      params[:id]
    end
end
