class CandiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_candy, only: [:show, :update, :destroy]

  def index
    @candies = current_user.candies.order(:name)
  end

  def show
    respond_to do |format|
      format.json
      format.html do
        @has_preferences = @candy.preferences.for_user(current_user).count > 0
        @lovers = @candy.lovers.order(:name).for_user(current_user)
        @haters = @candy.haters.order(:name).for_user(current_user)
        @likers = @candy.likers.order(:name).for_user(current_user)
        @dislikers = @candy.dislikers.order(:name).for_user(current_user)
      end
    end
  end

  def trends
    @popular_candies = Candy.popular.for_user(current_user).limit(5)
    @disliked_candies = Candy.disliked.for_user(current_user).limit(5)
    if hate_pref=Hate.for_user(current_user).sample
      @hated_candy = hate_pref.candy
      @hate_percentage = @hated_candy.percentage_hate(current_user)
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
      render action: 'show', status: :created
    else
      render json: @candy.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @candy.destroy
      respond_to do |format|
        format.json { render action: 'show' }
        format.html {
          redirect_to candies_path, notice: "Who needs #{@candy.name} anyway?"
        }
      end
    else
      respond_to do |format|
        format.json {
          render json: @candy.errors, status: :unprocessable_entity
        }
        format.html {
          redirect_to candy_path(@candy),
                      alert: "Could not delete #{@candy.name}."
        }
      end
    end
  end

  private

  def set_candy
    @candy = Candy.find(params[:id])
  end
end
