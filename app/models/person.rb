class Person < ActiveRecord::Base
  belongs_to :created_by_user, class_name: 'User'

  validates :name, :created_by_user, presence: true

  def to_s ; name ; end
end
