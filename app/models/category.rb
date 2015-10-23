##########################################################################
# The Category class is the primary model for holding information about
# infrastructure categories.
##########################################################################

class Category
  include Mongoid::Document

   # Add call to strip leading and trailing white spaces from all attributes
  strip_attributes  # See strip_attributes for more information

  ## CONSTANTS --------------------------------------------------------


  ## FIELDS -----------------------------------------------------------

  field :name, type: String
  field :description, type: String
  field :is_leaf, type: Mongoid::Boolean

  ## RELATIONSHIPS ----------------------------------------------------

  belongs_to :parent,   :class_name => :category
  has_many   :children, :class_name => :category

  ## DELEGATIONS ------------------------------------------------------


  ## VALIDATIONS ------------------------------------------------------

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :description
  validates_presence_of :is_leaf

  ## INDICES & SCOPES -------------------------------------------------

  ## PUBLIC INSTANCE METHODS ------------------------------------------

  ## CLASS METHODS ----------------------------------------------------


end
