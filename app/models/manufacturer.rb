##############################################################################
# The Manufacturer model class represents an example primary resource for the
# service. This model could be substituted with any primary resource
# that makes sense for your service. A primary resource is related to
# other resources in your system, to a user that created it, and to
# a group that can access it.
#
# The concept of a primary resource allows you to grant group access to
# the primary resource and any of its related resources.
##############################################################################

class Manufacturer
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  # Add call to strip leading and trailing white spaces from all attributes
  strip_attributes  # See strip_attributes for more information

  ## ATTRIBUTES -------------------------------------------------------

  field :name, type: String
  field :address, type: String
  field :website, type: String
  field :main_phone, type: String
  field :main_fax, type: String
  field :tags, type: String

  ## VALIDATIONS ------------------------------------------------------

  validates_presence_of :name
  validates_presence_of :address
  validates_presence_of :website
  validates_presence_of :main_phone
  validates_presence_of :main_fax
  validates_presence_of :tags

 ## RELATIONSHIPS ----------------------------------------------------
  embeds_many :contacts

 ## DELEGATIONS ------------------------------------------------------

 ## PUBLIC METHODS ---------------------------------------------------

  #####################################################################
  # Create a new manufacturer if the current user is Admin
  #####################################################################
  def self.create_with_user(manufacturer_params, user)
    if user.role == User::SERVICE_ADMIN
     manufacturer = Manufacturer.new(manufacturer_params)
     manufacturer
    end
  end

end
