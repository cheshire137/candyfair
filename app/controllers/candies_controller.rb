class CandiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_candy, only: [:show, :update]

  def index
    @candies = Candy.order(:name)
    user_selections = Hash[current_user.selections.includes(:candy).map {|s|
      [s.candy_id, s]
    }]
    @selections = @candies.map {|candy|
      if user_selections.key? candy.id
        user_selections[candy.id]
      else
        Selection.new(user: current_user, candy: candy, quantity: 0)
      end
    }
    set_candies_list
  end

  def show
    set_candies_list
  end

  def add
    success = true
    params[:selections].each do |candy_id, quantity|
      next if quantity.to_i == 0
      selection = Selection.new(candy_id: candy_id, user: current_user,
                                quantity: quantity)
      success = success and selection.save
    end
    if success
      flash[:notice] = 'Saved your current candy selection.'
    else
      flash[:alert] = 'Could not save all your current selections.'
    end
    redirect_to candies_path
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
