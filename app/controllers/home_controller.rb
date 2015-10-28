class HomeController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_if_no_data, only: [:index]

  def index
  end

  private

  def redirect_if_no_data
    if current_user.preferences.count < 1
      redirect_to people_path
    elsif current_user.selections.count < 1
      redirect_to candies_path
    end
  end
end
