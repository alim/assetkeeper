########################################################################
# The User model is responsible for holding information associated with
# a user account. This model is then used by the Devise GEM for user
# user authentication and sign in. The model has been upgraded to
# include timestamps and strip_attributes for removing leading and
# trailing white spaces.
########################################################################
class User
  include Mongoid::Document
  include Mongoid::Timestamps

  include UserRoles

  # Add call to strip leading and trailing white spaces from all attributes
  strip_attributes  # See strip_attributes for more information

  # Callback to check if related organization can be destroyed, if not
  # a Runtime Exception is raised. The calling code should catch this
  # on destroy method calls.
  before_destroy :check_org

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :timeoutable

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable

  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  field :authentication_token, :type => String

  ## CONSTANTS ----------------------------------------------------------

  # CUSTOMER ROLE - constant for specifying a customer role
  CUSTOMER = 1

  # SERVICE_ADMIN - constant for specify a service administrator
  SERVICE_ADMIN = 2

  ## Additional fields and validations ---------------------------------

  field :first_name, type: String, default: ''
  validates_presence_of :first_name

  field :last_name, type: String, default: ''
  validates_presence_of :last_name

  field :phone, type: String, default: ''
  validates_presence_of :phone

  validates :email, uniqueness: true

  field :role, type: Integer, default: CUSTOMER
  validates :role, inclusion: { in: [CUSTOMER, SERVICE_ADMIN],
    message: "is invalid" }


  ## RELATIONSHIPS -----------------------------------------------------

  belongs_to :organization, inverse_of: :users
  has_one :owns, class_name: 'Organization', inverse_of: :owner, dependent: :destroy

  has_one :subscription, dependent: :destroy
  embeds_one :account

  ## RESOURCES MANAGED BY A USER
  has_many :projects, dependent: :destroy
  has_many :asset_items, dependent: :destroy

  ## DELEGATIONS ------------------------------------------------------

  delegate :name, :description, to: :organization, prefix: true


  ## PUBLIC CLASS METHODS ----------------------------------------------

  #####################################################################
  # Class method to return the correct set of user records from a
  # search request.
  #####################################################################
  def self.search_by(search_type, search_term)
    # Check for the type of search we are doing
    case search_type
    when 'email'
      self.by_email(search_term)
    when 'first_name'
      self.by_first_name(search_term)
    when 'last_name'
      self.by_last_name(search_term)
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

  ## PUBLIC INSTANCE METHODS ------------------------------------------

  #####################################################################
  # Checks to see if its safe to delete the organization. If there are
  # other members in the organization and the current user is the owner
  # then ownership must be changed to another user. This method will
  # just raise a validation error.
  #####################################################################
  def check_org
    # Ok to delete if there is no organization related to the current
    # user object.
    return true unless self.owns?

    org = self.owns

    # Ok to delete if the organization is owned by the current user
    # and the current user is the only member
    return true if (org.users.count == 1) &&
      (org.users.first.email == self.email)

    # Cannot delete if there are other members in the organization
    if (org.users.count > 1)
      raise("Cannot delete User - related organization has other members. Please change ownership, before deleting your account.")
    end
  end
end

