class CandiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_candy, only: [:show, :update]

  def index
    @candies = Candy.order(:name)
    set_candies_list
  end

  def show
    set_candies_list
  end

  def trends
    @popular_candies = Candy.popular.limit(5)
    @disliked_candies = Candy.disliked.limit(5)
  end

  def create
    @candy = Candy.new(name: params[:name])
    if @candy.save
      set_candies_list
      render action: 'show', status: :created
    else
      render json: @candy.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @candy = Candy.find_by_name(params[:name])
    if @candy.destroy
      set_candies_list
      render action: 'show'
    else
      render json: @candy.errors, status: :unprocessable_entity
    end
  end

  private

  def set_candy
    @candy = Candy.find(params[:id])
  end

  def set_candies_list
    @candies ||= Candy.order(:name)
    @candies_list = @candies.select(:name).pluck(:name).to_sentence + '.'
  end
end
