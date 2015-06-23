class PingController < ApplicationController

  def index
    if signed_in?
      json = {"ping" => current_user.email}
    else
      json = {"ping" => "pong"}
    end

    render json: json
  end

end
