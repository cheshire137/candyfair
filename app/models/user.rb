class User < ActiveRecord::Base
  # :confirmable, :lockable, :timeoutable, :omniauthable, :registerable,
  # :recoverable, :rememberable, :validatable
  devise :database_authenticatable, :trackable, authentication_keys: [:username]

  validates :username, presence: true, uniqueness: {case_sensitive: false}
end
