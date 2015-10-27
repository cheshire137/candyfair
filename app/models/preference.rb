class Preference < ActiveRecord::Base
  VALID_TYPES = ['Like', 'Dislike', 'Love', 'Hate'].freeze

  belongs_to :candy
  belongs_to :person

  validates :candy, :person, :type, presence: true
  validates :type, uniqueness: {scope: [:candy_id, :person_id]}
  validates :type, inclusion: {in: VALID_TYPES}
end
