class Candy < ActiveRecord::Base
  before_validation :normalize_name

  validates :name, presence: true, uniqueness: true

  has_many :preferences, dependent: :destroy

  def to_s ; name ; end

  scope :order_by_preferences_count, ->(types) {
    joins(:preferences).where(preferences: {type: types}).
                        select('candies.*, ' +
                               'COUNT(preferences.id) AS preferences_count').
                        group('candies.id').order('preferences_count DESC')
  }

  scope :popular, ->{ order_by_preferences_count(%w(Like Love)) }

  scope :disliked, ->{ order_by_preferences_count(%w(Dislike Hate)) }

  def percentage_hate
    total_people = Person.count
    total_haters = Hate.where(candy_id: id).count
    ((total_haters / total_people.to_f) * 100).round
  end

  private

  def normalize_name
    return unless name
    self.name = name.strip.gsub(/,/, '')
  end
end
