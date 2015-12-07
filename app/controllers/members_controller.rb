class MembersController < ApplicationController

  def show
    member = Member.includes(model: :members).find_by_slug(params[:id])

    authorize member

    render json: member, include: ['model']
  end

end
