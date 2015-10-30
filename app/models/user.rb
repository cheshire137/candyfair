class User < ActiveRecord::Base
  # :confirmable, :lockable, :timeoutable, :omniauthable,
  # :recoverable, :rememberable, :validatable
  devise :database_authenticatable, :trackable, :registerable,
         authentication_keys: [:username]

  validates :username, presence: true, uniqueness: {case_sensitive: false}

  has_many :people, dependent: :destroy
  has_many :preferences, through: :people
  has_many :candies, dependent: :destroy

  after_create :add_american_candies

  def add_american_candies
    Candy::AMERICAN_SET.each do |name|
      Candy.create(name: name, user_id: id)
    end
  end
end
