class User < ActiveRecord::Base
  # :confirmable, :lockable, :timeoutable, :omniauthable, :registerable,
  # :recoverable, :rememberable, :validatable
  devise :database_authenticatable, :trackable, authentication_keys: [:username]

  validates :username, presence: true, uniqueness: {case_sensitive: false}

  has_many :people, foreign_key: 'created_by_user_id', dependent: :destroy
  has_many :preferences, through: :people
end
