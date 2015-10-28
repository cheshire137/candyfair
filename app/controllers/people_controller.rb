class PeopleController < ApplicationController
  before_action :authenticate_user!

  def index
    @people = current_user.people.includes(preferences: :candy).order(:name)
  end
end
