class HomeController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_if_no_data, only: [:index]

  def index
    @candies = Candy.order(:name)
    @favored_by_one = get_favored_by_one
  end

  private

  def get_favored_by_one
    favored_by_one = {}
    candies_favored_by_one = Candy.favored_by_one.order(:name)
    candies_favored_by_one.each do |candy|
      key = candy.preferences.first.person.name
      favored_by_one[key] ||= []
      favored_by_one[key] << candy.name
    end
    favored_by_one
  end

  def redirect_if_no_data
    if current_user.preferences.count < 1
      redirect_to people_path
    end
  end
end
