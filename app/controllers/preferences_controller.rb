class PreferencesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_person

  def index
    @candies = Candy.order(:name)
    @preferences = Hash[@candies.map {|c| [c.name, {candy: c}] }]
    @person.preferences.each do |preference|
      @preferences[preference.candy.name][:preference] = preference
      type = preference.type.downcase.to_sym
      @preferences[preference.candy.name][type] = true
    end
  end

  private

  def set_person
    @person = Person.find(params[:person_id])
  end
end
