class HomeController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_if_no_data, only: [:index]

  def index
    @candies = current_user.candies.order(:name)
    @favored_by_one = get_favored_by_one
    @favored_by_none = current_user.candies.favored_by_none.order(:name)
    @favored_by_many = get_favored_by_many
    @unrated = current_user.candies.unrated.order(:name)
    @has_preferences = current_user.preferences.count > 0
    @people = current_user.people.order(:name)
  end

  private

  def get_favored_by_many
    favored_by_many = {}
    candies = current_user.candies.favored_by_many.
                           includes(preferences: :person).order(:name)
    candies.each do |candy|
      key = candy.name
      favored_by_many[key] ||= {}
      favored_by_many[key][:id] = candy.id
      favored_by_many[key][:loves] = candy.loves.map(&:person)
      favored_by_many[key][:likes] = candy.likes.map(&:person)
    end
    favored_by_many
  end

  def get_favored_by_one
    favored_by_one = {}
    current_user.candies.favored_by_one.order(:name).each do |candy|
      person = candy.preferences.favorable.first.person
      key = person.name
      favored_by_one[key] ||= {}
      favored_by_one[key][:person_id] = person.id
      favored_by_one[key][:candies] ||= []
      favored_by_one[key][:candies] << candy
    end
    favored_by_one
  end

  def redirect_if_no_data
    if current_user.preferences.count < 1
      redirect_to people_path
    end
  end
end
