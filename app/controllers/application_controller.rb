class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActiveRecord::RecordNotFound do |ex|
    respond_to do |format|
      format.json { render json: {error: '404 Not Found'}, status: :not_found }
      format.html { render text: '404 Not Found', status: :not_found }
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:username, :password, :password_confirmation)
    end
    devise_parameter_sanitizer.for(:sign_in) do |u|
      u.permit(:username, :password)
    end
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:username, :password, :password_confirmation, :current_password)
    end
  end
end
