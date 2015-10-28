class Candy < ActiveRecord::Base
  before_validation :normalize_name

  validates :name, presence: true, uniqueness: true

  has_many :preferences, dependent: :destroy

  has_many :loves, class_name: 'Love'
  has_many :hates, class_name: 'Hate'
  has_many :likes, class_name: 'Like'
  has_many :dislikes, class_name: 'Dislike'

  has_many :lovers, through: :loves, source: :person
  has_many :haters, through: :hates, source: :person
  has_many :likers, through: :likes, source: :person
  has_many :dislikers, through: :dislikes, source: :person

  def to_s ; name ; end

  scope :order_by_preferences_count, ->(types) {
    joins(:preferences).where(preferences: {type: types}).
                        select('candies.*, ' +
                               'COUNT(preferences.id) AS preferences_count').
                        group(:id).order('preferences_count DESC')
  }

  scope :popular, ->{ order_by_preferences_count(%w(Like Love)) }

  scope :disliked, ->{ order_by_preferences_count(%w(Dislike Hate)) }

  scope :divisive, ->{
    loved_and_hated_candy_ids = Love.select(:candy_id).pluck(:candy_id) &
                                Hate.select(:candy_id).pluck(:candy_id)
    where(id: loved_and_hated_candy_ids).joins(:preferences).
        where(preferences: {type: %w(Love Hate)}).
        select('candies.*, ' +
               "SUM(CASE WHEN type='Love' THEN 1 ELSE 0 END) AS love_count, " +
               "SUM(CASE WHEN type='Hate' THEN 1 ELSE 0 END) AS hate_count").
        group(:id)
  }

  scope :favored_by_one, ->{
    candy_ids = Preference.favorable.select(:candy_id).group(:candy_id).
                           having('COUNT(id) = 1')
    where(id: candy_ids)
  }

  scope :favored_by_none, ->{
    favored_candy_ids = Preference.select(:candy_id).favorable
    where.not(id: favored_candy_ids).where(id: Preference.select(:candy_id))
  }

  scope :favored_by_many, ->{
    favored_candy_ids = Preference.select(:candy_id).favorable.
                                   group(:candy_id).having('COUNT(id) > 1')
    where(id: favored_candy_ids)
  }

  scope :boring, ->{
    opinionated_candy_ids = Preference.extremes.select(:candy_id)
    joins(:preferences).where.not(id: opinionated_candy_ids).group(:id).
        select('candies.*, COUNT(preferences.id) AS preferences_count').
        order('preferences_count DESC')
  }

  scope :unrated, ->{ where.not(id: Preference.select(:candy_id)) }

  def self.most_divisive limit
    divisive.sort_by {|candy|
      (candy.love_count - candy.hate_count).abs
    }.reverse[0...limit]
  end

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
