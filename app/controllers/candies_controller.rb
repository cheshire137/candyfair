class CandiesController < ApplicationController
  before_action :authenticate_user!

  def index
    @candies = Candy.order(:name)
    @people = current_user.people.order(:name)
  end
end
