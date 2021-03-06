class User < ActiveRecord::Base
  # :confirmable, :lockable, :timeoutable, :omniauthable,
  # :recoverable, :rememberable, :validatable, :trackable
  devise :database_authenticatable, :registerable,
         authentication_keys: [:username]

  validates :username, presence: true, uniqueness: {case_sensitive: false}
  validates :password, presence: true, confirmation: true,
                       if: :password_required?
  validates :password, length: {in: 6..72}

  has_many :people, dependent: :destroy
  has_many :preferences, through: :people
  has_many :candies, dependent: :destroy

  after_create :add_american_candies

  def add_american_candies
    Candy::AMERICAN_SET.each do |name, options|
      Candy.create(name: name, user_id: id, wikipedia_title: options[:title])
    end
  end

  private

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
end
