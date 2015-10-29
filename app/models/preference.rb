class Preference < ActiveRecord::Base
  VALID_TYPES = ['Like', 'Dislike', 'Love', 'Hate'].freeze

  belongs_to :candy
  belongs_to :person

  validates :candy, :person, :type, presence: true
  validates :candy_id, uniqueness: {scope: [:person_id]}
  validates :type, inclusion: {in: VALID_TYPES}
  validate :user_matches

  scope :for_user, ->(user) {
    joins(:person).where(people: {user_id: user})
  }

  scope :for_person, ->(person) { where(person_id: person) }

  scope :for_candy, ->(candy) { where(candy_id: candy) }

  scope :favorable, ->{ where(type: %w(Like Love)) }

  scope :extremes, ->{ where(type: %w(Love Hate)) }

  private

  def user_matches
    return unless candy && person
    unless candy.user_id == person.user_id
      errors.add(:candy, 'must be tied to the same user as the person.')
    end
  end
end
