class User < ActiveRecord::Base
  # :confirmable, :lockable, :timeoutable, :omniauthable,
  # :recoverable, :rememberable, :validatable
  devise :database_authenticatable, :trackable, :registerable,
         authentication_keys: [:username]

  validates :username, presence: true, uniqueness: {case_sensitive: false}

  has_many :people, dependent: :destroy
  has_many :preferences, through: :people
  has_many :candies, dependent: :destroy
end
