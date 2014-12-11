#######################################################################
# The Asset class is the primary model for holding information about
# infrastructure assets. It will rely on other classes for manufacturer
# and categories.
#######################################################################
class Asset
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::TagsArentHard

  # Scope definitions for organizational based queries
  include Organizational

  taggable_with :tags

  # Add call to strip leading and trailing white spaces from all atributes
  strip_attributes  # See strip_attributes for more information

  ## CONSTANTS --------------------------------------------------------

  # CONDITION VALUES

  EXCELLENT_CONDITION = 5
  VERY_GOOD_CONDITION = 4
  GOOD_CONDITION = 3
  POOR_CONDITION = 2
  VERY_POOR_CONDITION = 1

  # PROBABLILITY OF FAILURE

  IMMENENT_FAILURE = 5
  LIKELY_FAILURE = 4
  NEITHER_FAILURE = 3
  UNLIKELY_FAILURE = 2
  VERY_UNLIKELY_FAILURE = 1
  UNKNOWN_FAILURE = 0

  # CONSEQUENCE OF FAILURE

  EXTREMELY_HIGH_CONSEQUENCE = 5
  HIGH_CONSEQUENCE = 4
  MODERATE_CONSEQUENCE = 3
  LOW_CONSEQUENCE = 2
  VERY_LOW_CONSEQUENCE = 1

  # STATUS VALUES

  ORDERED_STATUS = 1
  IN_INVENTORY = 2
  SCHEDULED_FOR_INSTALLATION = 3
  OPERATIONAL = 4
  SCHEDULED_FOR_REPLACEMENT = 5
  REMOVED = 6
  DOWN_FOR_MAINTENANCE = 7

  ## FIELDS -----------------------------------------------------------

  field :name, type: String
  field :description, type: String
  field :location, type: String
  field :latitude, type: String
  field :longitude, type: String
  field :material, type: String
  field :date_installed, type: DateTime
  field :condition, type: Integer
  field :failure_probablity, type: Integer
  field :failure_consequence, type: Integer
  field :status, type: Integer

  ## RELATIONSHIPS ----------------------------------------------------

  belongs_to :user
  belongs_to :organization

  # Relationships needed in the near future
  # belongs_to :category
  # belongs_to :manufacturer

  ## VALIDATIONS ------------------------------------------------------

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :description
  validates_presence_of :material
  validates_presence_of :condition
  validates_presence_of :failure_probablity
  validates_presence_of :failure_consequence
  validates_presence_of :status
  validates_presence_of :user_id

  ## INDICES & SCOPES -------------------------------------------------

  index({name: 1}, {name: 'name_index'})
  index({condition: 1}, {name: 'condition_index'})
  index({status: 1}, {name: 'status_index'})

  scope :by_name, ->(name){ where(name: /^#{name}/i) }
  scope :by_category, ->(cat){ where(category: cat) }
  scope :by_status, ->(status){ where(status: status) }

  ## PUBLIC INSTANCE METHODS ------------------------------------------

  #####################################################################
  # Calculates the criticality by multiplying consequence x failure
  # probability.
  #####################################################################
  def criticality
    if self.failure_consequence && self.failure_probablity
      self.failure_consequence * self.failure_probablity
    else
      0
    end
  end

  ## PUBLIC CLASS METHODS ---------------------------------------------

  #####################################################################
  # Create a new Asset and relate the user record to it.
  #####################################################################
  def self.create_with_user(params, user)
     asset = Asset.new(params)
     asset.user = user
     asset
  end

end
