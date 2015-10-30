class Person < ActiveRecord::Base
  extend FriendlyId

  belongs_to :user

  validates :name, :user, presence: true
  validates :name, uniqueness: {scope: [:user_id]}

  friendly_id :name, use: [:slugged, :finders]

  has_many :preferences, dependent: :destroy
  has_many :loves
  has_many :hates
  has_many :likes
  has_many :dislikes

  has_many :favorable_preferences, ->{ where(type: %w(Love Like)) },
           class_name: 'Preference'

  has_many :unfavorable_preferences, ->{ where(type: %w(Hate Dislike)) },
           class_name: 'Preference'

  scope :for_user, ->(user) { where(user_id: user) }

  scope :with_preference_counts, ->{
    joins(:preferences).
        select('people.*, ' +
               "SUM(CASE WHEN type='Love' OR type='Like' THEN 1 ELSE 0 END) " +
               "AS favorable_count, " +
               "SUM(CASE WHEN type='Hate' OR type='Dislike' THEN 1 " +
               "ELSE 0 END) AS unfavorable_count").
        group(:id)
  }

  def to_s ; name ; end

  def self.order_by_pickiness user, limit
    for_user(user).with_preference_counts.select {|person|
      person.unfavorable_count > person.favorable_count
    }.sort_by {|person|
      person.favorable_count.to_f / person.unfavorable_count
    }[0...limit]
  end

  def preferences_summary
    types = {}
    preferences.joins(:candy).order('type DESC, candies.name ASC').each do |p|
      key = p.type.downcase + 's'
      types[key] ||= []
      types[key] << p.candy
    end
    if types.empty?
      types[''] = []
    end
    types
  end
end
