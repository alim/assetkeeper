#######################################################################
# This model is used to hold the contact request. It is not tied to
# a database table, but just holds the contents in memory. We do include
# ActiveModel validations to help validate the form entries.
#######################################################################
class Contact
  include Mongoid::Document
  include Mongoid::Timestamps

	# ACCESSORS ---------------------------------------------------------

  attr_accessor :name, :email, :phone, :body

	# VALIDATIONS -------------------------------------------------------

  validates :name, :email, :body, :presence => true
  validates :email, :format => { :with => %r{.+@.+\..+} }, :allow_blank => true

	# RELATIONSHIPS -------------------------------------------------------
  embedded_in :manufacturer

  # INSTANCE METHODS --------------------------------------------------

end
