class Preference < ActiveRecord::Base
  VALID_TYPES = ['Like', 'Dislike', 'Love', 'Hate'].freeze

  belongs_to :candy
  belongs_to :person

  validates :candy, :person, :type, presence: true
  validates :candy_id, uniqueness: {scope: [:person_id]}
  validates :type, inclusion: {in: VALID_TYPES}

  scope :for_person, ->(person) { where(person_id: person) }

  scope :for_candy, ->(candy) { where(candy_id: candy) }

  scope :favorable, ->{ where(type: %w(Like Love)) }

  scope :extremes, ->{ where(type: %w(Love Hate)) }
end
