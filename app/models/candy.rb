class Candy < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  has_many :preferences

  def to_s ; name ; end
end
