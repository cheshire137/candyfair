class User < ActiveRecord::Base
  # :confirmable, :lockable, :timeoutable, :omniauthable, :registerable,
  # :recoverable, :rememberable
  devise :database_authenticatable, :trackable, :validatable
end
