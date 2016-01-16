class SluggedRoutesController < ApplicationController

  def show
    slugged_route = SluggedRoute.includes(owner: :members).find_by_slug!(slug)

    authorize slugged_route

    render json: slugged_route, include: ["owner"]
  end

  def slug
    params[:id]
  end
end
