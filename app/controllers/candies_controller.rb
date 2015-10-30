class CandiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_candy, only: [:show, :update]

  def index
    @candies = current_user.candies.order(:name)
    set_candies_list
  end

  def show
    set_candies_list
  end

  def trends
    @popular_candies = Candy.popular.for_user(current_user).limit(5)
    @disliked_candies = Candy.disliked.for_user(current_user).limit(5)
    if hate_pref=Hate.for_user(current_user).sample
      @hated_candy = hate_pref.candy
      @hate_percentage = @hated_candy.percentage_hate
    end
    @boring_candies = Candy.boring.for_user(current_user).limit(5)
    @unrated_candies = Candy.unrated.for_user(current_user).order(:name).
                             pluck(:name)
    @divisive_candies = Candy.most_divisive(current_user, 5)
    @pickiest_eaters = Person.order_by_pickiness(current_user, 5)
  end

  def create
    @candy = current_user.candies.new(name: params[:name])
    if @candy.save
      set_candies_list
      render action: 'show', status: :created
    else
      render json: @candy.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @candy = current_user.candies.find_by_name(params[:name])
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
    @candies ||= current_user.candies.order(:name)
    if @candies.count > 0
      @candies_list = @candies.select(:name).pluck(:name).to_sentence + '.'
    else
      @candies_list = ''
    end
  end
end
