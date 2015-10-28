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

  def to_s ; name ; end

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
