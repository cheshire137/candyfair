class PreferencesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_person

  def index
    @candies = current_user.candies.order(:name)
    @preferences = Hash[@candies.map {|c| [c.name, {candy: c}] }]
    @person.preferences.for_candy(@candies).each do |preference|
      key = preference.candy.name
      @preferences[key][:preference] = preference
      type = preference.type.downcase.to_sym
      @preferences[key][type] = true
    end
  end

  def create
    @preference = Preference.for_person(@person).for_candy(params[:candy_id]).
                             first_or_initialize
    @preference.type = params[:type]
    unless @preference.save
      render json: @preference.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @preference = Preference.for_person(@person).for_candy(params[:candy_id]).
                             first
    unless @preference
      head :no_content
      return
    end
    if @preference.destroy
      head :no_content
    else
      render json: @preference.errors, status: :unprocessable_entity
    end
  end

  private

  def set_person
    @person = current_user.people.find(params[:person_id])
  end
end
