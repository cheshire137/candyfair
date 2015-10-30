class Candy < ActiveRecord::Base
  AMERICAN_SET = ['100 Grand', '3 Musketeers', '5th Avenue', 'AirHeads',
                  'Almond Joy', 'Bit-O-Honey', 'Bottle Caps', 'Butterfinger',
                  'Cadbury Cream Egg', 'Candy Cane', 'Candy Corn', 'Caramels',
                  'Charleston Chew', 'Circus Peanuts', 'Conversation Hearts',
                  'Cow Tales', 'Ding Dongs', 'Dots', 'Dum Dums', 'Fudge Rounds',
                  'Fun Dip', 'Gummi Worms', 'Heath', "Hershey's",
                  "Hershey's Kisses", 'Jelly Bellies', 'Jolly Rancher',
                  'Junior Mints', 'Kit Kat', 'LaffyTaffy', 'Lemonheads',
                  'Licorice', 'LifeSavers', 'Mars', 'Mary Janes',
                  'Mike and Ikes', 'Milk Duds', 'MilkyWay', 'M&Ms', 'Mounds',
                  'Necco Wafers', 'Nerds', 'Nestlé Crunch',
                  'Oatmeal Cream Pies', 'PayDay', 'Peach Rings', 'Peeps', 'Pez',
                  'Pixy Stix', 'RedVines', "Reese's Cups", "Reese's Pieces",
                  'Riesen', 'Rolos', 'Skittles', 'Smarties', 'Snickers',
                  'Sour Patch Kids', 'Starburst', 'Star Crunch', 'Swedish Fish',
                  'SweeTarts', 'Swiss Cake Rolls', 'Toblerone', 'Tootsie Roll',
                  'Tootsie Roll Pops', 'Trolli Strawberry Puffs', 'Twinkies',
                  'Twix', 'Twizzlers', 'WarHeads', 'Whatchamacallit',
                  'Whoppers', 'York Peppermint Patties', 'Zebra Cakes',
                  'Zero'].freeze

  belongs_to :user

  before_validation :normalize_name

  validates :name, :user, presence: true
  validates :name, uniqueness: {scope: [:user_id]}

  has_many :preferences, dependent: :destroy

  has_many :loves, class_name: 'Love'
  has_many :hates, class_name: 'Hate'
  has_many :likes, class_name: 'Like'
  has_many :dislikes, class_name: 'Dislike'

  has_many :lovers, through: :loves, source: :person
  has_many :haters, through: :hates, source: :person
  has_many :likers, through: :likes, source: :person
  has_many :dislikers, through: :dislikes, source: :person

  def to_s ; name ; end

  scope :for_user, ->(user) { where(user: user) }

  scope :order_by_preferences_count, ->(types) {
    joins(:preferences).where(preferences: {type: types}).
                        select('candies.*, ' +
                               'COUNT(preferences.id) AS preferences_count').
                        group(:id).order('preferences_count DESC')
  }

  scope :popular, ->{ order_by_preferences_count(%w(Like Love)) }

  scope :disliked, ->{ order_by_preferences_count(%w(Dislike Hate)) }

  scope :divisive, ->{
    loved_and_hated_candy_ids = Love.select(:candy_id).pluck(:candy_id) &
                                Hate.select(:candy_id).pluck(:candy_id)
    where(id: loved_and_hated_candy_ids).joins(:preferences).
        where(preferences: {type: %w(Love Hate)}).
        select('candies.*, ' +
               "SUM(CASE WHEN type='Love' THEN 1 ELSE 0 END) AS love_count, " +
               "SUM(CASE WHEN type='Hate' THEN 1 ELSE 0 END) AS hate_count").
        group(:id)
  }

  scope :favored_by_one, ->{
    candy_ids = Preference.favorable.select(:candy_id).group(:candy_id).
                           having('COUNT(id) = 1')
    where(id: candy_ids)
  }

  scope :favored_by_none, ->{
    favored_candy_ids = Preference.select(:candy_id).favorable
    where.not(id: favored_candy_ids).where(id: Preference.select(:candy_id))
  }

  scope :favored_by_many, ->{
    favored_candy_ids = Preference.select(:candy_id).favorable.
                                   group(:candy_id).having('COUNT(id) > 1')
    where(id: favored_candy_ids)
  }

  scope :boring, ->{
    opinionated_candy_ids = Preference.extremes.select(:candy_id)
    joins(:preferences).where.not(id: opinionated_candy_ids).group(:id).
        select('candies.*, COUNT(preferences.id) AS preferences_count').
        order('preferences_count DESC')
  }

  scope :unrated, ->{ where.not(id: Preference.select(:candy_id)) }

  def self.most_divisive user, limit
    divisive_candies = for_user(user).divisive
    return divisive_candies if divisive_candies.to_a.size < 1
    max_love_count = divisive_candies.max {|c| c.love_count }.love_count
    divisive_candies.sort {|candy_a, candy_b|
      candy_a_diff = (candy_a.love_count - candy_a.hate_count).abs
      candy_b_diff = (candy_b.love_count - candy_b.hate_count).abs

      candy_a_love = max_love_count - candy_a.love_count
      candy_b_love = max_love_count - candy_b.love_count

      [candy_a_diff, candy_a_love] <=> [candy_b_diff, candy_b_love]
    }[0...limit]
  end

  def percentage_hate
    total_people = Person.count
    total_haters = Hate.where(candy_id: id).count
    ((total_haters / total_people.to_f) * 100).round
  end

  private

  def normalize_name
    return unless name
    self.name = name.strip.gsub(/,/, '')
  end
end
