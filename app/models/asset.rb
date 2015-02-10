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

  CONDITION_VALUES = { excellent: 5, very_good: 4, good: 3, poor: 2, very_poor: 1}

  FAILURE_VALUES = { immenent: 5, likely: 4, neither: 3, unlikely: 2,
    very_unlikely: 1, unknown: 0 }

  CONSEQUENCE_VALUES = { extremely_high: 5, high: 4, moderate: 3, low: 2,
    very_low: 1}

  STATUS_VALUES = { ordered: 1, in_inventory: 2, scheduled_for_installation: 3,
    operational: 4, scheduled_for_replacement: 5, removed: 6, maintenance: 7}

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

  ## DELEGATIONS ------------------------------------------------------

  delegate :first_name, :last_name, to: :user, prefix: true
  delegate :name, to: :organization, prefix: true

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
