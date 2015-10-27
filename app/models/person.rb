class Person < ActiveRecord::Base
  belongs_to :created_by_user, class_name: 'User'

  validates :name, :created_by_user, presence: true
  validates :name, uniqueness: {scope: [:created_by_user_id]}

  has_many :preferences

  def to_s ; name ; end

  def preferences_summary
    if preferences.count < 1
      return 'no preferences'
    end
    types = {}
    preferences.map {|p|
      types[p.type] ||= []
      types[p.type] << p.candy.name
    }
    types.map {|type, candies|
      "#{type.downcase}s #{candies.join(', ')}"
    }.join('; ')
  end
end
