class LandingsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    redirect_to landings_show_path if user_signed_in?
  end
end
