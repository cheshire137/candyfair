module HasNameAndUser
  def self.extended kls
    kls.send :include, InstanceMethods
  end

  module InstanceMethods
    extend ActiveSupport::Concern

    included do
      friendly_id :slug_candidates, use: [:slugged, :finders]

      belongs_to :user

      validates :name, :user, presence: true
      validates :name, uniqueness: {scope: [:user_id]}

      scope :for_user, ->(user) { where(user_id: user) }
    end

    def to_s ; name ; end

    def slug_candidates
      [:name, [:name, :user_name]]
    end

    def user_name ; user.username ; end
  end
end
