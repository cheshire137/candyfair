class Person < ActiveRecord::Base
  extend FriendlyId

  belongs_to :created_by_user, class_name: 'User'

  validates :name, :created_by_user, presence: true
  validates :name, uniqueness: {scope: [:created_by_user_id]}

  friendly_id :name, use: [:slugged, :finders]

  has_many :preferences

  def to_s ; name ; end

  def preferences_summary
    types = {}
    preferences.each do |p|
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
