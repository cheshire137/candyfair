class HomeController < ApplicationController
  before_action :redirect_to_login, only: [:index]

  def index
    redirect_to candies_path
  end

  private

  def redirect_to_login
    unless user_signed_in?
      redirect_to new_user_session_path
    end
  end
end
