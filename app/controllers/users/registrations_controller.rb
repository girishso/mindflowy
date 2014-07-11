class Users::RegistrationsController < Devise::RegistrationsController
  include ApplicationHelper

  def create
    super
  end

  def new
    super
  end

  def edit
    super
  end

  def create_guest
    current_or_guest_user
    redirect_to root_url, info: "You are signed in as guest."
  end
end
