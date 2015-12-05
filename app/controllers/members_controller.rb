class MembersController < ApplicationController

  def show
    member = Member.find_by_slug(params[:id])

    # authorize member

    render json: member, include: ['model']
  end

end
