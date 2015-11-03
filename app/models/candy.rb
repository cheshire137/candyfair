require 'wikipedia'

class Candy < ActiveRecord::Base
  extend FriendlyId
  extend HasNameAndUser

  has_many :preferences, dependent: :destroy

  has_many :loves, class_name: 'Love'
  has_many :hates, class_name: 'Hate'
  has_many :likes, class_name: 'Like'
  has_many :dislikes, class_name: 'Dislike'

  has_many :lovers, through: :loves, source: :person
  has_many :haters, through: :hates, source: :person
  has_many :likers, through: :likes, source: :person
  has_many :dislikers, through: :dislikes, source: :person

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

  def percentage_hate user
    total_people = user.people.count
    total_haters = Hate.for_user(user).where(candy_id: id).count
    ((total_haters / total_people.to_f) * 100).round
  end

  def get_wikipedia
    query = wikipedia_title
    return unless query.present?
    return if skip_wikipedia?
    Wikipedia.find(query)
  end

  def wikipedia_title
    wikipedia_title? ? attributes['wikipedia_title'] : name
  end

  def self.update_user_candies
    american_candy_names = AMERICAN_SET.keys
    new_candy_count = 0
    users = User.all.select {|user|
      total = user.candies.count
      non_american_count = user.candies.
          where.not(name: american_candy_names).count
      non_american_pct = (non_american_count.to_f / total) * 100
      # Non-American candy percentage is low, meaning they mainly have candies
      # from the American set, or they don't have any candies yet at all.
      non_american_pct < 50 || total == 0
    }
    users.each do |user|
      AMERICAN_SET.select {|name, options|
        user.candies.where(name: name).count < 1
      }.each do |name, options|
        candy = Candy.create(user: user, name: name,
                             wikipedia_title: options[:title],
                             skip_wikipedia: options.key?(:skip))
        if candy.persisted?
          new_candy_count += 1
        end
      end
    end
    puts "Updated potentially #{users.size} #{'user'.pluralize users.size}: " +
         "#{users.map(&:username).join(', ')}"
    puts "Created #{new_candy_count} #{'candy'.pluralize new_candy_count}"
  end

  def self.update_wikipedia_data
    AMERICAN_SET.select {|name, options|
      options[:title].present? && !options.key?(:skip)
    }.each do |name, options|
      title = options[:title]
      Candy.where(name: name).
            where('wikipedia_title IS NULL OR wikipedia_title != ?', title).
            update_all(wikipedia_title: title)
    end
    AMERICAN_SET.select {|name, options|
      options.key?(:skip)
    }.each do |name, options|
      Candy.where(name: name).update_all(skip_wikipedia: true)
    end
  end

  AMERICAN_SET = {
    '100 Grand' => {title: nil},
    '3 Musketeers' => {title: '3 Musketeers (chocolate bar)'},
    '5th Avenue' => {title: '5th Avenue (candy)'},
    'AirHeads' => {title: nil},
    'Almond Joy' => {title: nil},
    'Baby Ruth' => {title: nil},
    'Bit-O-Honey' => {title: nil},
    'Bottle Caps' => {title: nil},
    'Butterfinger' => {title: nil},
    'Cadbury Cream Egg' => {title: nil},
    'Candy Cane' => {title: nil},
    'Candy Corn' => {title: nil},
    'Caramels' => {title: nil},
    'Charleston Chew' => {title: nil},
    'Circus Peanuts' => {title: nil},
    'Conversation Hearts' => {title: nil},
    'Cow Tales' => {title: nil, skip: true},
    'Ding Dongs' => {title: nil},
    'Dots' => {title: 'Dots (candy)'},
    'Dum Dums' => {title: 'Dum Dums (lollipop)'},
    'Fudge Rounds' => {title: nil},
    'Fun Dip' => {title: nil},
    'Gummi Worms' => {title: 'Gummi candy'},
    'Heath' => {title: 'Heath bar'},
    "Hershey's" => {title: nil, skip: true},
    "Hershey's Kisses" => {title: nil},
    'Jelly Bellies' => {title: 'Jelly Belly'},
    'Jolly Rancher' => {title: nil},
    'Junior Mints' => {title: nil},
    'Kit Kat' => {title: nil},
    'Laffy Taffy' => {title: nil},
    'Lemonheads' => {title: 'Lemonhead (candy)'},
    'Licorice' => {title: 'Liquorice (confectionery)'},
    'Life Savers' => {title: nil},
    'Mars' => {title: 'Mars (chocolate bar)'},
    'Mary Janes' => {title: 'Mary Jane (candy)'},
    'Mike and Ikes' => {title: nil},
    'Milk Duds' => {title: nil},
    'Milky Way' => {title: 'Milky Way (chocolate bar)'},
    'M&Ms' => {title: nil},
    'Mounds' => {title: 'Mounds (candy)'},
    'Necco Wafers' => {title: nil},
    'Nerds' => {title: 'Nerds (candy)'},
    'Nestlé Crunch' => {title: nil},
    'Oatmeal Cream Pies' => {title: nil, skip: true},
    'PayDay' => {title: 'PayDay (confection)'},
    'Peach Rings' => {title: nil, skip: true},
    'Peeps' => {title: nil},
    'Pez' => {title: nil},
    'Pixy Stix' => {title: nil},
    'RedVines' => {title: nil},
    "Reese's Cups" => {title: "Reese's Peanut Butter Cups"},
    "Reese's Pieces" => {title: nil},
    'Riesen' => {title: nil},
    'Rolos' => {title: nil},
    'Skittles' => {title: 'Skittles (confectionery)'},
    'Smarties' => {title: 'Smarties (wafer candy)'},
    'Snickers' => {title: nil},
    'Sour Patch Kids' => {title: nil},
    'Spree' => {title: 'Spree (candy)'},
    'Starburst' => {title: 'Starburst (confectionery)'},
    'Star Crunch' => {title: nil, skip: true},
    'Swedish Fish' => {title: nil},
    'SweeTarts' => {title: nil},
    'Swiss Cake Rolls' => {title: nil, skip: true},
    'Toblerone' => {title: nil},
    'Tootsie Roll' => {title: nil},
    'Tootsie Roll Pops' => {title: nil},
    'Trolli Strawberry Puffs' => {title: nil, skip: true},
    'Twinkies' => {title: nil},
    'Twix' => {title: nil},
    'Twizzlers' => {title: nil},
    'WarHeads' => {title: 'Warheads (candy)'},
    'Whatchamacallit' => {title: 'Whatchamacallit (candy)'},
    'Whoppers' => {title: nil},
    'York Peppermint Patties' => {title: nil},
    'Zagnut' => {title: nil},
    'Zebra Cakes' => {title: nil, skip: true},
    'Zero' => {title: 'ZERO bar'},
  }.freeze
end
