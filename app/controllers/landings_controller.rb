class LandingsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :about]

  def index
  end
end
