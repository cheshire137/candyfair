class CandiesController < ApplicationController
  before_action :authenticate_user!

  def index
    @candies = Candy.order(:name)
  end
end
