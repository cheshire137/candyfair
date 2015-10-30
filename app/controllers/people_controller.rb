class PeopleController < ApplicationController
  before_action :authenticate_user!
  before_action :set_person, only: [:show, :destroy]

  def index
    @people = current_user.people.includes(preferences: :candy).order(:name)
    @has_preferences = current_user.preferences.count > 0
    @has_candies = current_user.candies.count > 0
  end

  def show
  end

  def create
    @person = current_user.people.new(name: params[:name])
    if @person.save
      render action: 'show', status: :created
    else
      render json: @person.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @person.destroy
      redirect_to people_path, notice: "#{@person.name} had it coming."
    else
      redirect_to person_preferences_path(@person),
                  alert: "Could not remove #{@person.name}."
    end
  end

  private

  def set_person
    @person = current_user.people.find(params[:id])
  end
end
