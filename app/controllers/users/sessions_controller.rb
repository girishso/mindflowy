class Users::SessionsController < Devise::SessionsController
  skip_filter :authenticate_user_from_token!

  include ApplicationHelper

  def create
    puts "sdasdsdasdada"
    super
  end

  def new
    super
  end
end
