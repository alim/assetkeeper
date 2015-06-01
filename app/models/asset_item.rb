#######################################################################
# The Asset class is the primary model for holding information about
# infrastructure assets. It will rely on other classes for manufacturer
# and categories.
#######################################################################
class AssetItem
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Taggable

  include Organizational
  include UserCreatable

  # Add call to strip leading and trailing white spaces from all attributes
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
  field :failure_probability, type: Integer
  field :failure_consequence, type: Integer
  field :status, type: Integer
  field :part_number, type: String
  field :model_type, type: String
  field :serial_number, type: String

  field :title
  field :content

  ## RELATIONSHIPS ----------------------------------------------------

  belongs_to :user
  belongs_to :organization
  belongs_to :manufacturer

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
  validates_presence_of :part_number
  validates_presence_of :model_type
  validates_presence_of :serial_number
  validates_presence_of :condition
  validates_presence_of :failure_probability
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
  scope :by_manufacturer, ->(manufacturer_id){ where(:manufacturer_id => manufacturer_id) }
  scope :by_tag, ->(tag){ self.tagged_with(/^#{tag}/i) }

  ## PUBLIC INSTANCE METHODS ------------------------------------------

  #####################################################################
  # Calculates the criticality by multiplying consequence x failure
  # probability.
  #####################################################################
  def criticality
    if failure_consequence && failure_probability
      failure_consequence * failure_probability
    else
      0
    end
  end

  ## CLASS METHODS ----------------------------------------------------

  #####################################################################
  # Class method to return the correct set of asset records from a
  # search request.
  #####################################################################
  def self.search_by(search_type, search_term)
    # Check for the type of search we are doing
    case search_type
    # Search for Manufacturers
     when 'manufacturer_id'

      if (mid = find_manufacturer_id(search_term))
        by_manufacturer(mid)
      else
        all
      end
    # Search for Tags
     when 'tags'
      if search_term && (search_term.length > 0)
        self.by_tag(search_term)
      else
       self.all
      end
    else # Unrecognized search type so return all
      all
    end
  end

  #####################################################################
  # Class method to filter by role
  #####################################################################
  def self.filter_by(filter)
    case filter
    when 'customer'
      by_role(User::CUSTOMER)
    when 'service_admin'
      by_role(User::SERVICE_ADMIN)
    else
      all
    end
  end

  #####################################################################
  # Helper class method to find the manufacturer's id based on the
  # search term.
  #####################################################################
  def self.find_manufacturer_id(search_term)
    return nil unless search_term && (search_term.length > 0)
    manu = Manufacturer.where(name: /^#{search_term}/i).last
    manu ? manu.id : nil
  end

  private_class_method :find_manufacturer_id
end
