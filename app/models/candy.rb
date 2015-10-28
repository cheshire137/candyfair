class Candy < ActiveRecord::Base
  before_validation :normalize_name
  validates :name, presence: true, uniqueness: true

  has_many :preferences, dependent: :destroy

  def to_s ; name ; end

  private

  def normalize_name
    return unless name
    self.name = name.strip.gsub(/,/, '')
  end
end
