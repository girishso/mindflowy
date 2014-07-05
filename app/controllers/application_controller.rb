class ApplicationController < ActionController::Base
  layout "retro"

  before_filter :authenticate_user_from_token!
  before_action :authenticate_user!

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?
  helper_method :current_or_guest_user

  # if user is logged in, return current_user, else return guest_user
  def current_or_guest_user
    if current_user
      if session[:guest_user_id]
        logging_in
        #guest_user.destroy
        session[:guest_user_id] = nil
      end
      current_user
    else
      guest_user
    end
  end

  # find guest_user object associated with the current session,
  # creating one as needed
  def guest_user
    # Cache the value the first time it's gotten.
    @cached_guest_user ||= User.find(session[:guest_user_id] ||= create_guest_user.id)

  rescue ActiveRecord::RecordNotFound # if session[:guest_user_id] invalid
     session[:guest_user_id] = nil
     guest_user
  end

  protected

  #->Prelang (user_login:devise)
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up)        { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in)        { |u| u.permit(:login, :username, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
  end


  private

    #-> Prelang (user_login:devise)
    def require_user_signed_in
      unless user_signed_in?

        # If the user came from a page, we can send them back.  Otherwise, send
        # them to the root path.
        if request.env['HTTP_REFERER']
          fallback_redirect = :back
        elsif defined?(root_path)
          fallback_redirect = root_path
        else
          fallback_redirect = "/"
        end

        redirect_to fallback_redirect, flash: {error: "You must be signed in to view this page."}
      end
    end

    def authenticate_user!(opts={})
    puts "in authenticate_user **************************"
    pp opts
      opts[:scope] = :user
      warden.authenticate!(opts) if !devise_controller? || opts.delete(:force)
    end

    # For this example, we are simply using token authentication
    # via parameters. However, anyone could use Rails's token
    # authentication features to get the token from a header.
    def authenticate_user_from_token!
      puts request.format
      return true if request.format != "application/json"

      authenticate_or_request_with_http_token do |token, options|
        # User.find_by(auth_token: token)
        user       = token && User.find_by_authentication_token(token.to_s)
        if user
          sign_in user, store: false
        end
        user
      end

      # Notice how we use Devise.secure_compare to compare the token
      # in the database with the token given in the params, mitigating
      # timing attacks.
    end

    # called (once) when the user logs in, insert any code your application needs
    # to hand off from guest_user to current_user.
    def logging_in
      # For example:
      # guest_comments = guest_user.comments.all
      # guest_comments.each do |comment|
        # comment.user_id = current_user.id
        # comment.save!
      # end
    end

    def create_guest_user
      guest_id = "#{Time.now.to_i}#{rand(99)}"
      u = User.new(:name => "guest#{guest_id}", :email => "guest_#{guest_id}@example.com", :password => "secret_key")
      u.save!(:validate => false)
      session[:guest_user_id] = u.id
      u
    end
end
