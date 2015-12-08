class MembersController < ApplicationController

  def show
    member = Member.includes(model: :members).find_by_slug!(member_slug)

    authorize member

    render json: member, include: ['model']
  end

  def member_slug
    params[:id]
  end

end
