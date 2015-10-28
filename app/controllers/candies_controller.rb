class CandiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_candy, only: [:show, :update]
  before_action :set_candies_list, only: [:index, :show]

  def index
    @candies = Candy.order(:name)
  end

  def show
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

  def update
    @candy.name = params[:name]
    if @candy.save
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
    @candies_list = Candy.order(:name).select(:name).pluck(:name).
                          to_sentence + '.'
  end
end
