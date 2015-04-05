#######################################################################
# The Asset class is the primary model for holding information about
# infrastructure assets. It will rely on other classes for manufacturer
# and categories.
#######################################################################
class AssetItem
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::TagsArentHard

  include Organizational
  include UserCreatable

  taggable_with :tags

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

  ## PUBLIC INSTANCE METHODS ------------------------------------------

  #####################################################################
  # Class method to return the correct set of asset records from a
  # search request.
  #####################################################################
  def self.search_by(search_type, search_term)
    # Check for the type of search we are doing
    case search_type
    when 'manufacturer_id'

      if search_term == nil
        self.all
      else
        @manu = Manufacturer.where(name: search_term)

        if @manu.count == 0
          self.all
        else
          @search_manufacturer_id = @manu.last.id

          if @search_manufacturer_id == nil
           self.all
          else
           self.by_manufacturer(@search_manufacturer_id)
          end
        end
      end
    else # Unrecognized search type so return all
      self.all
    end
  end

  #####################################################################
  # Class method to filter by role
  #####################################################################
  def self.filter_by(filter)
    case filter
    when 'customer'
      self.by_role(User::CUSTOMER)
    when 'service_admin'
      self.by_role(User::SERVICE_ADMIN)
    else
      self.all
    end
  end

  #####################################################################
  # Calculates the criticality by multiplying consequence x failure
  # probability.
  #####################################################################
  def criticality
    if self.failure_consequence && self.failure_probability
      self.failure_consequence * self.failure_probability
    else
      0
    end
  end
end
