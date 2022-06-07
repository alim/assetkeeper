##########################################################################
# The Organizational concern's purpose is to add features associated
# with working with the Organizational model to class that belong
# to an organization.
##########################################################################
module UserCreatable
  extend ActiveSupport::Concern

  ## CLASS METHODS ----------------------------------------------------

  module ClassMethods
    ########################################################################
    # Create a new Object and relate the user record to it.
    ########################################################################
    def create_with_user(params, user)
      new_object = new(params)
      new_object.user = user
      new_object
    end
  end
end
