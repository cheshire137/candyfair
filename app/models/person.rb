class Person < ActiveRecord::Base
  belongs_to :created_by_user, class_name: 'User'

  validates :name, :created_by_user, presence: true
  validates :name, uniqueness: {scope: [:created_by_user_id]}

  has_many :preferences

  def to_s ; name ; end
end
