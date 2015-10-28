class PeopleController < ApplicationController
  before_action :authenticate_user!

  def index
    @people = current_user.people.includes(preferences: :candy).order(:name)
  end

  def show
    @person = current_user.people.find(params[:id])
  end

  def create
    @person = current_user.people.new(name: params[:name])
    if @person.save
      render action: 'show', status: :created
    else
      render json: @person.errors, status: :unprocessable_entity
    end
  end
end
